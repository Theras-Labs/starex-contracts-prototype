import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers, network } from "hardhat";
import { BigNumber, Signer } from "ethers";
import {
  BTC_VALUE,
  DECIMALS,
  WETH_VALUE,
  convertToUSD,
  convertUnits,
} from "../../tasks/helpers/utils";
require("mocha-reporter").hook();

async function deployFixture() {
  // Contracts are deployed using the first signer/account by default
  const [deployer, bank, alice, bob, charlie] = await ethers.getSigners();

  // FACTORIES
  const ledgerFactory = await ethers.getContractFactory("PaymasterLedger");

  // DEPLOY
  const ledger = await ledgerFactory.deploy(
    bank.address,
    bank.address,
    BigNumber.from("10000000000000000000"), //around 10 usd if ledger's currency equal usd
    BigNumber.from("10000000000000000000000000") //around 100k usd if ledger's currency equal usd
  );

  // Get the ABI of the deployed ledger
  const ledgerAbi = ledgerFactory.interface.format("json");
  return {
    ledger,
    ledgerAbi,
    bank,
    bob,
    alice,
    charlie,
  };
}

describe("Paymaster Ledger  ", function () {
  let ledger: any;
  let ledgerAbi: any;
  let alice: Signer;
  let charlie: Signer;
  let bob: Signer;
  let bank: Signer;

  before(async function () {
    // Initialize the contract and other variables once before all tests
    ({ ledger, ledgerAbi, bank, alice, bob, charlie } = await loadFixture(
      deployFixture
    ));
  });

  it("Should be able to make deposit", async function () {
    console.log("All starting balances should be 0 Ledger currency (L-USD)");
    await getAllBalancesExpectZero(alice, bob, charlie, ledger);
    // MAKING DEPOSIT
    console.log("Alice deposit 1.5k usd");
    await expect(
      ledger.connect(alice).deposit(
        alice.address,
        BigNumber.from("1500000000000000000000") // 1.5k usd
      )
    ).to.not.be.reverted;

    console.log("Bob deposit 33k usd");
    await expect(
      ledger.connect(bob).deposit(
        bob.address,
        BigNumber.from("33000000000000000000000") // 33k usd
      )
    ).to.not.be.reverted;

    console.log("Charlie deposit 5k usd");
    await expect(
      ledger.connect(charlie).deposit(
        charlie.address,
        BigNumber.from("5000000000000000000000") // 5k usd
      )
    ).to.not.be.reverted;
  });

  it("Should be zero after deposit before approvals", async function () {
    console.log("balances should stay zero after approvals");
    await getAllBalancesExpectZero(alice, bob, charlie, ledger);
  });

  it("Should be updated after approvals", async function () {
    console.log("Bank updating all approvals");
    await expect(ledger.connect(bank).bankApprove(alice.address, 1, true)).to
      .not.be.reverted;
    await expect(ledger.connect(bank).bankApprove(bob.address, 1, true)).to.not
      .be.reverted;
    console.log("Bank reject charlie tx");
    await expect(ledger.connect(bank).bankApprove(charlie.address, 1, false)).to
      .not.be.reverted;

    await getAllBalances(alice, bob, charlie, ledger);
  });

  it("Should be able to execute transfer", async function () {
    console.log("Alice sending 1k to charlie ");
    await expect(
      ledger.connect(alice).transferFrom(
        alice.address,
        charlie.address,
        BigNumber.from("1000000000000000000000") // 1k usd
      )
    ).to.not.be.reverted;

    console.log("Rich Bob sending 10k to charlie ");
    await expect(
      ledger.connect(bob).transferFrom(
        bob.address,
        charlie.address,
        BigNumber.from("10000000000000000000000") // 10k usd
      )
    ).to.not.be.reverted;

    console.log("Broke Charlie will fail to transfer with balance 0");
    await expect(
      ledger.connect(charlie).transferFrom(
        charlie.address,
        alice.address,
        BigNumber.from("10000000000000000000000") // 10k usd
      )
    ).to.be.revertedWith("Insufficient balance");
    console.log("balances before approving transferFrom");
    await getAllBalances(alice, bob, charlie, ledger);
  });

  it("Should be proceed after self approval and bank approval", async function () {
    console.log("Alice approve before bank ");
    await expect(ledger.connect(alice).approve(2)).to.not.be.reverted;

    console.log("bank making batch approvals");
    await expect(
      ledger
        .connect(bank)
        .batchBankApprove([alice.address, bob.address], [2, 2], [true, true])
    ).to.not.be.reverted;
    console.log(
      "Showing all balances after bank approve alice and bob, and alice did approve too"
    );
    await getAllBalances(alice, bob, charlie, ledger);

    console.log("Bob approve after bank ");
    await expect(ledger.connect(bob).approve(2)).to.not.be.reverted;
    console.log("Showing all balances after bob approving");
    await getAllBalances(alice, bob, charlie, ledger);
  });

  it("Should be able to see data off-chain by events", async function () {
    console.log("Showing the lists");
    const ledgerInterface = new ethers.utils.Interface(ledgerAbi);

    // Fetch historical logs for the contract
    const filter = {
      // address: alice.address,
      fromBlock: 0, // Adjust the fromBlock as needed
      toBlock: "latest", // You can specify the block range
    };

    const logs = await ledger.provider.getLogs(filter);

    // Separate events into different arrays based on their names
    const transactionInitiatedEvents = [];
    const transactionProcessedEvents = [];

    // Parse and categorize the events
    logs.forEach((log) => {
      const event = ledgerInterface.parseLog(log);

      if (event.name === "TransactionInitiated") {
        transactionInitiatedEvents.push(event);
      } else if (event.name === "TransactionProcessed") {
        transactionProcessedEvents.push(event);
      }
    });
    // console.log(transactionProcessedEvents,'transactionInitiatedEvents')

    console.log(
      "list transactions init events:",
      transactionInitiatedEvents.map(
        (item, i) =>
          `${item.args[1]}  ${
            !!Number(BigNumber.from(item.args[0])) ? "Transfer" : "Deposit"
          } ${convertUnits(item.args[3])}`
      )
    );
    console.log("list transactions bank approvals:");
    console.log(
      "Feel free to adjustment, like showing pending tx not approved yet, etc"
    );
  });
});

const getAllBalances = async (alice, bob, charlie, ledger) => {
  const ALICE_BALANCE = await ledger.connect(alice).balanceOf(alice.address);
  console.log(`Alice balance is :${convertUnits(ALICE_BALANCE)}`);
  // Bob's balance
  const BOB_BALANCE = await ledger.connect(bob).balanceOf(bob.address);
  console.log(`Bob balance is: ${convertUnits(BOB_BALANCE)}`);
  // Charlie's balance
  const CHARLIE_BALANCE = await ledger
    .connect(charlie)
    .balanceOf(charlie.address);
  console.log(`Charlie balance is: ${convertUnits(CHARLIE_BALANCE)}`);
};

const getAllBalancesExpectZero = async (alice, bob, charlie, ledger) => {
  const ALICE_BALANCE = await ledger.connect(alice).balanceOf(alice.address);
  await expect(ALICE_BALANCE).to.equal(BigNumber.from("0"));

  console.log(`Alice balance is :${convertUnits(ALICE_BALANCE)}`);
  // Bob's balance
  const BOB_BALANCE = await ledger.connect(bob).balanceOf(bob.address);

  await expect(BOB_BALANCE).to.equal(BigNumber.from("0"));
  console.log(`Bob balance is: ${convertUnits(BOB_BALANCE)}`);

  // Charlie's balance
  const CHARLIE_BALANCE = await ledger
    .connect(charlie)
    .balanceOf(charlie.address);
  await expect(CHARLIE_BALANCE).to.equal(BigNumber.from("0"));
  console.log(`Charlie balance is: ${convertUnits(CHARLIE_BALANCE)}`);
};

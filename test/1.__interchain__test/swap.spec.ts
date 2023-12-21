import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers, network } from "hardhat";
import { BigNumber } from "ethers";
import {
  BTC_VALUE,
  DECIMALS,
  WETH_VALUE,
  convertToUSD,
  convertUnits,
} from "../../tasks/helpers/utils";
require("mocha-reporter").hook();

describe("Atomic Swap Scenarios ", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployFixture() {
    // Contracts are deployed using the first signer/account by default
    const [deployer, bank, alice, bob, charlie] = await ethers.getSigners();

    // FACTORIES

    const extendedLedgerFactory = await ethers.getContractFactory(
      "ExtendedLedger"
    );
    const swapFactory = await ethers.getContractFactory("SwapContract");
    const mockV3AggregatorFactory = await ethers.getContractFactory(
      "MockV3Aggregator"
    );
    const currencyERC20 = await ethers.getContractFactory("Currency");

    // CONTRACT DEPLOYMENT

    // // get an instance of the contract
    const contractWETH = await currencyERC20.deploy("WETH", "WETH");
    const contractWBTC = await currencyERC20.deploy("WBTC", "WBTC");
    const mockV3AggregatorWETH = await mockV3AggregatorFactory.deploy(
      DECIMALS,
      WETH_VALUE
    );
    const mockV3AggregatorBTC = await mockV3AggregatorFactory.deploy(
      DECIMALS,
      BTC_VALUE
    );

    const extendedLedger = await extendedLedgerFactory.deploy(
      bank.address,
      bank.address,
      BigNumber.from("10000000000000000000"), //around 10 usd if ledger's currency equal usd
      BigNumber.from("10000000000000000000000000") //around 100k usd if ledger's currency equal usd
    );

    const swapContract = await swapFactory.deploy(
      extendedLedger.address, //as currency, can change any ERC20 too USDC,WETH
      extendedLedger.address
    );

    // CONTRACT SETUP
    await extendedLedger
      .connect(deployer)
      .changeOperatorAddress(swapContract.address);

    await swapContract.connect(deployer).addPoolDetails(
      0, //fee
      0, // zero for now
      0, // zero for now
      contractWETH.address,
      mockV3AggregatorWETH.address,
      "WETH/USD"
    );

    await swapContract.connect(deployer).addPoolDetails(
      0, //fee
      0, // zero for now
      0, // zero for now
      contractWBTC.address,
      mockV3AggregatorBTC.address,
      "BTC/USD"
    );

    await contractWETH.connect(deployer).mint(
      alice.address,
      BigNumber.from("30000000000000000000") // 30 weth
    );
    await contractWBTC.connect(deployer).mint(
      bob.address,
      BigNumber.from("4000000000000000000")
      // 4 WBTC
    );
    await contractWETH.connect(deployer).mint(
      bank.address,
      BigNumber.from("100000000000000000000")

      // 100 ETH
    );

    return {
      contractWETH,
      contractWBTC,
      mockV3AggregatorWETH,
      mockV3AggregatorBTC,
      extendedLedger,
      swapContract,
      bank,
      bob,
      alice,
      charlie,
    };
  }

  it("Should verify that each address has their own currency", async function () {
    const {
      bank,
      alice,
      bob,
      contractWETH,
      contractWBTC,
      extendedLedger,
      swapContract,
    } = await loadFixture(deployFixture);
    // Inside the test cases
    // Check that Alice has 30 WETH
    const aliceWETHBalance = await contractWETH.balanceOf(alice.address);
    const formattedAliceWETH = convertToUSD(
      aliceWETHBalance,
      WETH_VALUE,
      DECIMALS
    );
    console.log(`Alice WETH: ${formattedAliceWETH} USD`);
    expect(aliceWETHBalance).to.equal(
      BigNumber.from("30000000000000000000"),
      "Alice WETH Balance does not match"
    );

    // Check that Alice's extendedLedger balance is 0
    const aliceLedgerBalance = await extendedLedger.balanceOf(alice.address);
    console.log(
      `Alice ExtendedLedger: ${ethers.utils.formatUnits(
        aliceLedgerBalance,
        18
      )} USD`
    );
    expect(aliceLedgerBalance).to.equal(
      BigNumber.from("0"),
      "Alice ExtendedLedger Balance does not match"
    );

    // Check that Bob has 4 WBTC
    const bobWBTCBalance = await contractWBTC.balanceOf(bob.address);
    const formattedBobWBTC = convertToUSD(bobWBTCBalance, BTC_VALUE, DECIMALS);
    console.log(`Bob WBTC: ${formattedBobWBTC} USD`);
    expect(bobWBTCBalance).to.equal(
      BigNumber.from("4000000000000000000"),
      "Bob WBTC Balance does not match"
    );

    // Check that Bob's extendedLedger balance is 0
    const bobLedgerBalance = await extendedLedger.balanceOf(bob.address);
    console.log(
      `Bob ExtendedLedger: ${ethers.utils.formatUnits(
        bobLedgerBalance,
        18
      )} USD`
    );
    expect(bobLedgerBalance).to.equal(
      BigNumber.from("0"),
      "Bob ExtendedLedger Balance does not match"
    );

    // Check that Bank has 100 ETH
    const bankETHBalance = await contractWETH.balanceOf(bank.address);
    const formattedBankETH = convertToUSD(bankETHBalance, WETH_VALUE, DECIMALS);
    console.log(`Bank ETH: ${formattedBankETH} USD`);
    expect(bankETHBalance).to.equal(
      BigNumber.from("100000000000000000000"),
      "Bank ETH Balance does not match"
    );

    // Check that Bank's extendedLedger balance is 0
    const bankLedgerBalance = await extendedLedger.balanceOf(bank.address);
    console.log(
      `Bank ExtendedLedger: ${ethers.utils.formatUnits(
        bankLedgerBalance,
        18
      )} USD`
    );
    expect(bankLedgerBalance).to.equal(
      BigNumber.from("0"),
      "Bank ExtendedLedger Balance does not match"
    );

    // Check that Swap contract or liquidity
    const LiquidityPoolCurrency = await extendedLedger.balanceOf(
      swapContract.address
    );
    const formattedLiquidityPoolCurrency = convertToUSD(
      LiquidityPoolCurrency,
      WETH_VALUE,
      DECIMALS
    );
    console.log(
      `Swap Contract ExtendedLedger: ${formattedLiquidityPoolCurrency} USD`
    );

    const LiquidityPoolWETH = await contractWETH.balanceOf(
      swapContract.address
    );
    const formattedLiquidityPoolWETH = convertToUSD(
      LiquidityPoolWETH,
      WETH_VALUE,
      DECIMALS
    );
    console.log(`Swap Contract WETH: ${formattedLiquidityPoolWETH} USD`);

    const LiquidityPoolWBTC = await contractWBTC.balanceOf(
      swapContract.address
    );
    const formattedLiquidityPoolWBTC = convertToUSD(
      LiquidityPoolWBTC,
      BTC_VALUE,
      DECIMALS
    );
    console.log(`Swap Contract WBTC: ${formattedLiquidityPoolWBTC} USD`);

    expect(LiquidityPoolCurrency).to.equal(
      BigNumber.from("0"),
      "Swap Contract ExtendedLedger Balance does not match"
    );
    expect(LiquidityPoolWETH).to.equal(
      BigNumber.from("0"),
      "Swap Contract WETH Balance does not match"
    );
    expect(LiquidityPoolWBTC).to.equal(
      BigNumber.from("0"),
      "Swap Contract WBTC Balance does not match"
    );
  });

  it("Should be able to swap, and all balances are correct", async function () {
    const {
      bank,
      alice,
      bob,
      contractWETH,
      contractWBTC,
      extendedLedger,
      swapContract,
    } = await loadFixture(deployFixture);

    // Alice approves her WETH to swap
    console.log("Alice approve WETH usage to swap");
    await contractWETH.connect(alice).approve(
      swapContract.address,
      BigNumber.from("300000000000000000000000") // 300 ETH
    );

    // Alice swaps her 3 WETH to deposit into ledger = 6K USD
    console.log("Alice swaps 3 WETH to deposit into ledger = 6k usd");
    await swapContract.connect(alice).swap(
      contractWETH.address,
      BigNumber.from("3000000000000000000"), // 3 ETH
      extendedLedger.address
    );

    // Alice's balance of WBTC is zero
    const aliceWETHBalanceAfterSwap = await contractWETH.balanceOf(
      alice.address
    );
    console.log(
      `Alice WETH Balance After Swap: ${convertToUSD(
        aliceWETHBalanceAfterSwap,
        WETH_VALUE,
        DECIMALS
      )}`
    );
    expect(aliceWETHBalanceAfterSwap).to.be.lt(
      BigNumber.from("30000000000000000000"),
      "Alice WETH Balance After Swap should less than 30 WETH"
    );

    // Alice's ledger balance is still 0
    const aliceLedgerBalanceAfterSwap = await extendedLedger.balanceOf(
      alice.address
    );
    console.log(
      `Alice ExtendedLedger Balance After Swap: ${convertToUSD(
        aliceLedgerBalanceAfterSwap,
        BTC_VALUE,
        DECIMALS
      )} , should zero before approval`
    );
    expect(aliceLedgerBalanceAfterSwap).to.equal(
      BigNumber.from("0"),
      "Alice ExtendedLedger Balance After Swap is not 0"
    );

    // Bank approves Alice's deposit
    console.log("Bank approve the deposit");
    await extendedLedger.connect(bank).bankApprove(alice.address, 1, true);

    // Alice's ledger balance is still zero now
    const aliceLedgerBalanceAfterDeposit = await extendedLedger.balanceOf(
      alice.address
    );
    console.log(
      `Alice ExtendedLedger Balance After Approval: ${convertUnits(
        aliceLedgerBalanceAfterDeposit
      )} `
    );
    expect(aliceLedgerBalanceAfterDeposit).to.not.equal(
      BigNumber.from("0"),
      "Alice ExtendedLedger Balance After Deposit is still 0"
    );

    // Alice wants to swap BTC for 1000 USD out of her ledger's balance
    console.log(
      `Alice wants to swap BTC for 1000 USD out of her ledger's balance`
    );

    // Attempt to swap WBTC without sufficient liquidity and expect it to fail
    await expect(
      swapContract.connect(alice).swap(
        extendedLedger.address,
        BigNumber.from("1000000000000000000000"), // 1,000 USD
        contractWBTC.address
      )
    ).to.be.revertedWith("Insufficient Liquidity");
    console.log("Alice cannot swap due to Liquidity WBTC");

    // Alice's ledger balance is still the same
    const aliceLedgerBalanceAfterSwapAgain = await extendedLedger.balanceOf(
      alice.address
    );
    console.log(
      `Alice ExtendedLedger Balance After Second Swap: ${convertUnits(
        aliceLedgerBalanceAfterSwapAgain
      )}`
    );
    expect(aliceLedgerBalanceAfterSwapAgain).to.equal(
      aliceLedgerBalanceAfterDeposit,
      "Alice ExtendedLedger Balance after trying the swap  fail"
    );

    // Bob wants to deposit BTC for luqiduity
    console.log(`Bob wants to deposit WBTC for liquidity`);
    // Bob approves his WBTC
    console.log(`Bob approve WBTC`);

    await expect(
      contractWBTC.connect(bob).approve(
        swapContract.address,
        BigNumber.from("4000000000000000000") // 4 WBTC
      )
    ).to.not.be.reverted;

    // Bob swaps 4 WBTC to deposit into ledger = 8K USD
    console.log(`Bob swaps 4 WBTC`);
    await expect(
      swapContract.connect(bob).swap(
        contractWBTC.address,
        BigNumber.from("4000000000000000000"), // 4 WBTC
        extendedLedger.address
      )
    ).to.not.be.reverted;

    // Bank approves Bob's deposit
    console.log(`Bank approves bob deposit`);

    await expect(extendedLedger.connect(bank).bankApprove(bob.address, 1, true))
      .to.not.be.reverted;
    // todo: bank reject if bob it's too big and yet WBTC is already sent

    // Bob's USD increased in ledger
    const bobLedgerBalance = await extendedLedger.balanceOf(bob.address);
    console.log(
      `Bob ExtendedLedger: ${ethers.utils.formatUnits(
        bobLedgerBalance,
        18
      )} USD`
    );

    console.log("WBTC Liquidity has increased ");
    const WBTC_liquidty = await contractWBTC.balanceOf(swapContract.address);
    console.log(
      `Liquidty of WBTC now: ${convertToUSD(
        WBTC_liquidty,
        BTC_VALUE,
        DECIMALS
      )} `
    );

    console.log("Alice can retry to swap WBTC with liquidity now");
    await expect(
      swapContract.connect(alice).swap(
        extendedLedger.address,
        BigNumber.from("1000000000000000000000"), // 1,000 USD
        contractWBTC.address
      )
    ).to.not.be.reverted;

    console.log("Bank approves of the tx");
    // Bank approves the transaction
    await extendedLedger.connect(bank).bankApprove(alice.address, 2, true);

    console.log(
      "Alice balance still not update as alice hasnt approved it yet"
    );
    const BALANCE_ALICE = await extendedLedger.balanceOf(alice.address);
    console.log(
      `Alice ExtendedLedger: ${ethers.utils.formatUnits(BALANCE_ALICE, 18)} USD`
    );

    console.log(`Alice approve his swaps`);
    await expect(extendedLedger.connect(alice).approve(2)).to.not.be.reverted;

    const BALANCE_ALICE_LEDGER = await extendedLedger.balanceOf(alice.address);
    console.log(
      `Alice ledger balance now decreased ExtendedLedger: ${ethers.utils.formatUnits(
        BALANCE_ALICE_LEDGER,
        18
      )} USD`
    );

    const BALANCE_ALICE_WBTC = await contractWBTC.balanceOf(alice.address);
    console.log(
      `Alice WBTC now increased: ${convertToUSD(
        BALANCE_ALICE_WBTC,
        BTC_VALUE,
        DECIMALS
      )} `
    );
    const BALANCE_LIQUIDITY_WBTC = await contractWBTC.balanceOf(
      swapContract.address
    );
    console.log(
      `WBTC liquidty now: ${convertToUSD(
        BALANCE_LIQUIDITY_WBTC,
        BTC_VALUE,
        DECIMALS
      )} `
    );
  });
});

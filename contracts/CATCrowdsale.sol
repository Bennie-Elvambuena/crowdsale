pragma solidity ^0.4.11;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/crowdsale/FinalizableCrowdsale.sol";
import "./TokensCappedCrowdsale.sol";
import "./PausableCrowdsale.sol";
import "./BonusCrowdsale.sol";
import "./CAToken.sol";


contract CATCrowdsale is FinalizableCrowdsale, TokensCappedCrowdsale(CATCrowdsale.CAP), PausableCrowdsale(true), BonusCrowdsale(CATCrowdsale.TOKEN_USDCENT_PRICE, CATCrowdsale.DECIMALS) {

    // Constants
    uint256 public constant DECIMALS = 18;
    uint256 public constant CAP = 2 * (10**9) * (10**DECIMALS);              // 2B CAT
    uint256 public constant BITCLAVE_AMOUNT = 1 * (10**9) * (10**DECIMALS);  // 1B CAT
    uint256 public constant PRESALE_AMOUNT = 150 * (10**6) * (10**DECIMALS); // 150M CAT
    uint256 public constant TOKEN_USDCENT_PRICE = 7;                         // $0.07

    // Variables
    address public remainingTokensWallet;

    function setRemainingTokensWallet(address _remainingTokensWallet) public onlyOwner {
        remainingTokensWallet = _remainingTokensWallet;
    }

    // Events
    event TokenMint(address indexed beneficiary, uint256 amount);
    event WalletChange(address wallet);
    event RateChange(uint256 rate);

    // Constructor
    function CATCrowdsale(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate,
        address _wallet,
        address _remainingTokensWallet,
        address _bitClaveWallet,
        address _presaleWallet
    )
        Crowdsale(_startTime, _endTime, _rate, _wallet)
    {
        remainingTokensWallet = _remainingTokensWallet;

        BONUS_TIMES = [
            1 hours,
            1 days,
            7 days,
            30 days,
            45 days,
            60 days
        ];

        BONUS_TIMES_VALUES = [
            150,
            100,
            70,
            50,
            20,
            0
        ];

        BONUS_AMOUNTS = [
            900000,
            600000,
            450000,
            300000,
            225000,
            150000,
            90000,
            60000,
            45000,
            30000,
            22500,
            15000,
            9000,
            6000,
            4500,
            3000,
            2100,
            1500,
            900,
            600,
            300
        ];

        BONUS_AMOUNTS_VALUES = [
            130,
            120,
            110,
            100,
            90,
            80,
            70,
            65,
            60,
            55,
            50,
            45,
            40,
            35,
            30,
            25,
            20,
            15,
            10,
            5,
            0
        ];

        mintTokens(_bitClaveWallet, BITCLAVE_AMOUNT);
        mintTokens(_presaleWallet, PRESALE_AMOUNT);
    }

    // Overrided methods
    function createTokenContract() internal returns(MintableToken) {
        return new CAToken();
    }

    // Owner methods
    function mintTokens(address beneficiary, uint256 tokens) public onlyOwner {
        require(beneficiary != 0x0);
        require(token.totalSupply() + tokens <= tokensCap); // TokensCappedCrowdsale
        
        token.mint(beneficiary, tokens);
        TokenMint(beneficiary, tokens);
    }

    function finalize() onlyOwner public {
        if (token.totalSupply() < tokensCap) {
            mintTokens(remainingTokensWallet, tokensCap - token.totalSupply());
        }
        super.finalize();
        token.transferOwnership(owner);
    }

    function setWallet(address _wallet) external onlyOwner {
        require(_wallet != 0x0);
        wallet = _wallet;
        WalletChange(_wallet);
    }

    function setRate(uint256 _rate) external onlyOwner {
        require(_rate != 0x0);
        rate = _rate;
        RateChange(_rate);
    }

}

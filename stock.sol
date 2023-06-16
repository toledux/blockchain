// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

//0x8eE5B68e89d86f5662d02200cD0FF7baa8065067

contract Ownable {
    address internal owner;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can execute this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }
}

contract Stock is Ownable{
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event IPO(string indexed msg, address indexed owner, uint256 amount);

    struct Stockholder{
        address identity;
        uint256 stocks;
        bool isStockholder;
    }

    string public name;
    string public symbol;
    uint8 public immutable decimals;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    address[] private indexStockholders;
    mapping(address => Stockholder) public stockholders;
    

    uint256 internal immutable INITIAL_CHAIN_ID;
    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;
    mapping(address => uint256) public nonces;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 amountOfStocks
    ) {
        name = _name;
        symbol = _symbol;
        decimals = 0;
        indexStockholders.push(msg.sender);
        stockholders[msg.sender] = Stockholder(msg.sender, amountOfStocks, true);
        balanceOf[msg.sender] = amountOfStocks;
        totalSupply=amountOfStocks;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();

        emit IPO("successful IPO",msg.sender, amountOfStocks);
    }

    modifier isSellerAStockholder(){
        require(stockholders[msg.sender].isStockholder, "The order was rejected because the sender is not a stockholder of the company.");
        _;
    }

    modifier hasEnoughStocks(address seller, uint256 amount){
        require(stockholders[seller].stocks >= amount, "The order was rejected because of insufficient stocks available.");
        _;
    }

    function transfer(
        address buyer, uint256 amountOfStocks
    ) public virtual isSellerAStockholder hasEnoughStocks(msg.sender,amountOfStocks) returns (bool) {
        stockholders[msg.sender].stocks -= amountOfStocks;
        balanceOf[msg.sender] -= amountOfStocks;
        require( completeTransfer(buyer, amountOfStocks), "Transfer not completed");
        
        emit Transfer(msg.sender, buyer, amountOfStocks);
        return true;
    }

    function transferFrom(
        address seller,
        address buyer,
        uint256 amountOfStocks
    ) public virtual hasEnoughStocks(seller, amountOfStocks) returns (bool) {
        stockholders[seller].stocks -= amountOfStocks;
        balanceOf[seller] -= amountOfStocks;

        require( completeTransfer(buyer, amountOfStocks), "Transfer not completed");

        emit Transfer(seller, buyer, amountOfStocks);
        return true;
    }


    function completeTransfer(address buyer, uint256 amountOfStocks) internal returns(bool){
        if(!stockholders[buyer].isStockholder){
            stockholders[buyer] = Stockholder(buyer, amountOfStocks, true);
            indexStockholders.push(buyer);
            balanceOf[buyer] = amountOfStocks;
        } else {
            stockholders[buyer].stocks += amountOfStocks;
            balanceOf[buyer] += amountOfStocks;
        }

        return true;
    }


    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    function bonus(uint16 bonusFactor) public onlyOwner {
        for(uint256 i; i < indexStockholders.length; i++){
            uint256 amountOfStocks = stockholders[indexStockholders[i]].stocks*bonusFactor/100;
            stockholders[indexStockholders[i]].stocks += amountOfStocks;
            balanceOf[indexStockholders[i]] += amountOfStocks;
            totalSupply+=amountOfStocks;

            emit Transfer(address(0), stockholders[indexStockholders[i]].identity, amountOfStocks);
        }
        
    }

    function burnStocksInTreasury(uint256 amountOfStocks) external onlyOwner hasEnoughStocks(stockholders[owner].identity, amountOfStocks) {
        stockholders[owner].stocks -= amountOfStocks;
        balanceOf[owner] -= amountOfStocks;
        totalSupply -=totalSupply;

        emit Transfer(owner, address(0), amountOfStocks);
    }

    function percentageOfCompany() external view returns(uint256){
        return stockholders[msg.sender].stocks * 100 / totalSupply;
    }

    function stocks() external view returns (uint256){
        return stockholders[msg.sender].stocks;
    }
}
//Retirei os uncheckeds

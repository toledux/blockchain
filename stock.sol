// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

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

    struct Stockholder{
        address identity;
        uint256 stocks;
        bool isStockholder;
    }

    string public name;
    string public symbol;
    uint8 public immutable decimals;

    uint256 public treasury;
    mapping(address => Stockholder) public stockholders;
    mapping(address => mapping(address => uint256)) public allowance;

    uint256 internal immutable INITIAL_CHAIN_ID;
    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;
    mapping(address => uint256) public nonces;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    modifier isSellerAStockholder(){
        require(stockholders[msg.sender].isStockholder, "The sender is not a stockholder of the company.");
        _;
    }

    modifier hasEnoughStocksToSell(uint256 amount){
        require(stockholders[msg.sender].stocks >= amount, "Seller doesn't have enough stocks.");
        _;
    }

    function transfer(address buyer, uint256 amount) public virtual isSellerAStockholder hasEnoughStocksToSell(amount) returns (bool) {
        stockholders[msg.sender].stocks -= amount;
        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            stockholders[buyer].stocks += amount;
        }
        emit Transfer(msg.sender, buyer, amount);
        return true;
    }

    function transferFrom(
        address seller,
        address buyer,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[seller][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[seller][msg.sender] = allowed - amount;

        stockholders[seller].stocks -= amount;
        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            stockholders[buyer].stocks += amount;
        }
        emit Transfer(seller, buyer, amount);
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );
            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");
            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
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

    function bonus(uint256 amount) public onlyOwner {
        treasury += amount;
        
        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            stockholders[to].stocks += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function burn(address from, uint256 amount) public onlyOwner {
        stockholders[from].stocks -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            treasury -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}

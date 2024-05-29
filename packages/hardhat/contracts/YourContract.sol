//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// Useful for debugging. Remove when deploying to a live network.
import "hardhat/console.sol";

// Use openzeppelin to inherit battle-tested implementations (ERC20, ERC721, etc)
// import "@openzeppelin/contracts/access/Ownable.sol";??

/**
 * A smart contract that allows changing a state variable of the contract and tracking the changes
 * It also allows the owner to withdraw the Ether in the contract
 * @author BuidlGuidl
 */
 /**
 * @title Nairoverse - A marketplace for in-game assets on Lisk
 * @author [Martian]
 */
contract Nairoverse is LiskTransaction {
    // State variables
    address payable public owner; // Contract owner address
    uint256 public nextGameId; // Counter for generating unique game IDs
    uint256 public nextNftId; // Counter for generating unique NFT IDs

    // Game data structure
    struct Game {
        uint256 id; // Unique game identifier
        string name; // Game name
        address payable developer; // Address of the developer who registered the game
        string genre; // Optional genre of the game
        string description; // Optional description of the game
    }

    // NFT (in-game asset) data structure
    struct NFT {
        uint256 id; // Unique NFT identifier
        uint256 gameId; // ID of the game this NFT belongs to (reference to Game struct)
        address payable owner; // Current owner of the NFT
        string assetType; // Type of in-game asset (e.g., weapon, skin, character)
        string rarityLevel; // Rarity level of the NFT (e.g., common, rare, epic)
        // Optional metadata field can be added here for additional attributes
    }

    // Mapping of game IDs to Game structs
    mapping(uint256 => Game) public games;

    // Mapping of NFT IDs to NFT structs
    mapping(uint256 => NFT) public nfts;

    // Event emitted when a new game is registered
    event GameRegistered(uint256 id, string name, address developer);

    // Event emitted when a new NFT is created
    event NFTCreated(uint256 id, uint256 gameId, address owner);

    // Event emitted when an NFT is transferred (purchased)
    event NFTTransferred(uint256 id, address from, address to, uint256 price);

    // Modifier to restrict functions to contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Constructor (called upon deployment)
    constructor() public {
        owner = payable(msg.sender); // Set contract owner as the deployer
        nextGameId = 1; // Initialize ID counters
        nextNftId = 1;
    }

    // Register a new game on the marketplace (Lisk transaction)
    function registerGame(
        string memory _name,
        string memory _genre,
        string memory _description
    ) public payable transaction {
        uint256 newGameId = nextGameId++; // Generate unique game ID

        games[newGameId] = Game({
            id: newGameId,
            name: _name,
            developer: payable(msg.sender),
            genre: _genre,
            description: _description
        });

        emit GameRegistered(newGameId, _name, msg.sender);
    }

    // Function to generate a secure random number (for Lisk, use chain-specific method)
    function generateRandomNumber() private view returns (uint256) {
        // Replace with Lisk's secure random number generation function
        return uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), msg.sender))); 
    }

    // Create a new NFT (in-game asset) associated with a registered game (Lisk transaction)
    function createNFT(
    uint256 _gameId,
    string memory _assetType,
    string memory _rarityLevel
) public payable transaction {
    require(games[_gameId].id > 0, "Invalid game ID"); // Check if game exists

    uint256 newNftId = generateRandomNumber(); // Use secure random number generation
    while (nfts[newNftId].id > 0) {
        newNftId = generateRandomNumber(); // Prevent duplicate IDs
    }

    nfts[newNftId] = NFT({
        id: newNftId,
        gameId: _gameId,
        owner: payable(msg.sender), // Deployer initially owns the NFT
        assetType: _assetType,
        rarityLevel: _rarityLevel
    });

    emit NFTCreated(newNftId, _gameId, msg.sender);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract AudiusMock {
    address public admin;
    uint public rewardThreshold = 5; // số lượt nghe để nhận thưởng
    uint public rewardAmount = 10; // đơn vị AUDIO giả định

    struct Artist {
        string name;
        uint listens;
        uint balance; // AUDIO giả định
        bool registered;
    }

    struct Listener {
        string name;
        bool registered;
    }

    mapping(address => Artist) public artists;
    mapping(address => Listener) public listeners;

    event ArtistRegistered(address artist, string name);
    event ListenerRegistered(address listener, string name);
    event Listened(address listener, address artist);
    event RewardGiven(address artist, uint amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    modifier onlyRegisteredListener() {
        require(listeners[msg.sender].registered, "Not a registered listener");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function registerArtist(string memory _name) public {
        require(!artists[msg.sender].registered, "Already registered");
        artists[msg.sender] = Artist(_name, 0, 0, true);
        emit ArtistRegistered(msg.sender, _name);
    }

    function registerListener(string memory _name) public {
        require(!listeners[msg.sender].registered, "Already registered");
        listeners[msg.sender] = Listener(_name, true);
        emit ListenerRegistered(msg.sender, _name);
    }

    function listenTo(address _artist) public onlyRegisteredListener {
        require(artists[_artist].registered, "Artist not found");

        artists[_artist].listens += 1;
        emit Listened(msg.sender, _artist);

        // Nếu đạt ngưỡng, thưởng AUDIO giả định
        if (artists[_artist].listens % rewardThreshold == 0) {
            artists[_artist].balance += rewardAmount;
            emit RewardGiven(_artist, rewardAmount);
        }
    }

    // Xem thông tin nghệ sĩ
    function getArtistInfo(address _artist) public view returns (string memory, uint, uint) {
        Artist memory a = artists[_artist];
        return (a.name, a.listens, a.balance);
    }
}

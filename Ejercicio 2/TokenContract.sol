// SPDX-License-Identifier: Unlicenced
pragma solidity 0.8.30;
contract TokenContract {
    address public owner;
    struct Receivers {
        string name;
        uint256 tokens;
    }
    mapping(address => Receivers) public users;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() {
        owner = msg.sender;
        users[owner].tokens = 100;
    }

    function double(uint _value) public pure returns (uint) {
        return _value * 2;
    }

    function register(string memory _name) public {
        users[msg.sender].name = _name;
    }

    function giveToken(address _receiver, uint256 _amount) public onlyOwner {
        require(users[owner].tokens >= _amount);
        users[owner].tokens -= _amount;
        users[_receiver].tokens += _amount;
    }

    // --- FUNCIONALIDAD AÑADIDA PARA EL EJERCICIO 2 ---

    // Comprar tokens enviando Ether (1 token = 5 Ether)
    function buyTokens(uint256 _amount) public payable {
        uint256 cost = _amount * 5 ether;
        
        require(msg.value >= cost, "Ether enviado insuficiente (1 token = 5 ETH)");
        require(users[owner].tokens >= _amount, "El propietario no tiene suficientes tokens disponibles");

        users[owner].tokens -= _amount;
        users[msg.sender].tokens += _amount;
    }

    // Devuelve la cantidad de Ether almacenada en el Smart Contract
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract myTokenERC20 is ERC20 {
    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // endereco -> saldo | 1º mapping ex:
    // endereco -> 53120
    // endereco -> 31293
    // endereco -> 38239

    // endereco -> endereco -> 5000 | 2º mapping - primeiro endereco(minha wallet), segundo endereco(endereco das DEXs), 5000(valor allowances) ex:
    // endereco -> endereco -> 5000
    //          -> endereco -> 7000
    //          -> endereco -> 12000

    //event Transfer(address indexed _from, address indexed _to, uint256 _value);
    //event Approval(address indexed _owner, address indexed _spender, uint256 _value)

    constructor(uint initialSupply) ERC20("Joao Rambo Token", "JRT") {
        _mint(msg.sender, initialSupply);
    }

    function totalSupply() public override view returns(uint256) {
        return _totalSupply;
    }

    function decimals() public override view returns(uint8) {
        return 18;
    }

    function balanceOf(address _owner) public override view returns(uint256) {
        return _balances[_owner];
    }

    function transfer(address recipient, uint256 amount) public override returns(bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns(bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceed allowance");

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }

    function approve(address spender, uint amount) public override returns(bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public override returns(bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] += addedValue);
        
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public override returns(bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];

        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");

        unchecked{_approve(msg.sender, spender, currentAllowance - subtractedValue);}
        
        return true;
    }

    function _approve(address owner, address spender, uint amount) internal override {
        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    } 

    // função para transferir dinheiro(amount)
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20 transfer amount exeeds balance");

        unchecked{_balances[sender] = senderBalance - amount;}

        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal override {
        _totalSupply += amount;
        _balances[account] += amount;

        emit Transfer(address(0), account, amount);
    }

}
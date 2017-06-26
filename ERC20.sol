contract ERC20 {
    // ERC20 State
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowances;
    uint256 totalSupply;

    // Human State
    string public name;
    uint8 public decimals;
    string public version;
    string public symbol;

    // Minter State
    address public centralMinter;

    // Backed By Ether State
    uint256 public buyPrice;
    uint256 public sellPrice;

    // Modifiers
    modifier onlyMinter() {
        if (msg.sender != centralMinter) throw;
        _;
    }

    // ERC20 Events
    event Transfer(address indexed _from, address indexed _to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 value);

    // Constructor
    function ERC20(uint256 _initialAmount) {
        balances[msg.sender] = _initialAmount;
        totalSupply = _initialAmount;
    }

    // ERC20 Functions
    function balanceOf(address _address) constant returns (uint256 balance) {
        return balances[_address];
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[_to] + _value < balances[_to]) throw;
        if (balances[msg.sender] >= _value) {
            balances[msg.sender] -= _value;
            balances[_to] += value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowances[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _spender, address _to, uint256 _value) returns (bool success) {
        if (balances[_to] + _value < balances[_to]) throw;
        if (balances[_owner][msg.sender] >= _value && balances[_owner] >= value) {
            balances[_owner] -= _value;
            balances[_to] -= _value;
            allowances[_owner][msg.sender] -= _value;
            Transfer(_owner, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    // Minter Functions
    function mint(uint256 _amountToMint) onlyMinter() {
        balances[centralMinter] += _amountToMint;
        totalSupply += _amountToMint;
        Transfer(this, centralMinter, _amountToMint)
    }

    function transferMinter(address _newMinter) onlyMinter() {
        centralMinter = _newMinter;
    }

    // Backed By Ether Functions
    // Must instantiate contract with enough Ether to pay for ALL tokens
    function setPrices(uint256 _newSellPrice, uint256 _newBuyPrice) onlyMinter() {
        buyPrice = _newBuyPrice;
        sellPrice = _newSellPrice;
    }

    function buy() payable returns (uint256 amount) {
        amount = msg.value / buyPrice;
        if (balances[centralMinter] < amount) throw;
        balances[centralMinter] -= amount;
        balances[msg.sender] += amount;
        Transfer(centralMinter, msg.sender, amount);
        return amount;
    }

    function sell(uint256 _amount) payable returns (uint256 revenue) {
        if (balances[msg.sender] < _amount) throw;
        balances[centralMinter] += amount;
        balances[msg.sender] -= amount;
        revenue = _amount + sellPrice;
        if (!msg.sender.send(revenue)) {
            throw;
        } else {
            Transfer(msg.sender, centralMinter, _amount);
            return revenue;
        }
    }
}

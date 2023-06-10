//SPDX-License-Identifier: CC-BY-4.0

pragma solidity 0.8.20;

contract Bonus {
    string public nomeDoVendedor;
    uint256 public fatorDoBonus;
    uint256 public valorDaVenda;

    function atribuirValores(string memory nomeVendedor, uint256 fatorBonus, uint256 valorVenda) public {
        nomeDoVendedor = nomeVendedor;
        valorDaVenda = valorVenda;
        fatorDoBonus = fatorBonus;
    }
    
    function calcularBonus() public view returns (uint256) {
        return  valorDaVenda * fatorDoBonus / 100;
    }
}
//0x2318B93D0184A569Dd02e1822d4108b2aF07319a

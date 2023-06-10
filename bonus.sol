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
//0xd064A7CDBeD149Cf7d8C90Ca32bbAC40b5D1d92D

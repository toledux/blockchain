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
//0xa803D522EE5cEd67b38DFa090798A51e7A3F39D9

//SPDX-License-Identifier: CC-BY-4.0

pragma solidity 0.8.20;

//0xF48271227483f717F9fE08296360B45e0A70C5cC
contract Aula3 {
    uint256 constant NUMERO_MAXIMO_DE_PARCELAS = 36; 
    uint256 constant TIPO_PESSOA_LOCADOR = 1;
    uint256 constant TIPO_PESSOA_LOCATARIO = 2;

    string private nomeDoLocador;
    string private nomeDoLocatario;
    uint256[NUMERO_MAXIMO_DE_PARCELAS] private parcelasDoAluguel;

    constructor(string memory _nomeDoLocador, string memory _nomeDoLocatario, uint256 valorInicialDasParcelas) {
        nomeDoLocador = _nomeDoLocador;
        nomeDoLocatario = _nomeDoLocatario;
        for (uint8 i=0; i<NUMERO_MAXIMO_DE_PARCELAS; i++){
            parcelasDoAluguel[i]=valorInicialDasParcelas;
        }
    }

    function retornarValorDoAluguel(uint256 posicaoDaParcela) public view returns(uint256 valorDaParcela) {
        return parcelasDoAluguel[posicaoDaParcela -1];
    }

    function retornarNomeDoLocadorELocatario() public view returns(string memory, string memory){
        return (nomeDoLocador, nomeDoLocatario);
    }

    function alterarNome(uint256 tipoPessoa, string memory nome) public returns(bool){
        if(tipoPessoa == TIPO_PESSOA_LOCADOR){
            nomeDoLocador = nome;
            return true;
        } else if (tipoPessoa == TIPO_PESSOA_LOCATARIO){
            nomeDoLocatario = nome;
            return true;
        } 
        return false;
    }

    function reajustarParcelas(uint256 posicaoDaParcelaInicialParaReajuste, uint256 valorDoReajuste) public {
        for (uint256 i = posicaoDaParcelaInicialParaReajuste-1; i < NUMERO_MAXIMO_DE_PARCELAS; i++){
            parcelasDoAluguel[i] = parcelasDoAluguel[i] + valorDoReajuste;
        }
    }

}

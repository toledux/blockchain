//SPDX-License-Identifier: CC-BY-4.0

pragma solidity 0.8.20;

//0xF48271227483f717F9fE08296360B45e0A70C5cC
contract Aula3 {
    uint256 constant NUMERO_MAXIMO_DE_PARCELAS = 36; 
    uint256 constant TIPO_PESSOA_LOCADOR = 1;
    uint256 constant TIPO_PESSOA_LOCATARIO = 2;

    //string private nomeDoLocador;
    //string private nomeDoLocatario;
    //uint256[NUMERO_MAXIMO_DE_PARCELAS] private parcelasDoAluguel;
    struct ContratoLocacao{
        string nomeDoLocador;
        string nomeDoLocatario;
        uint256[NUMERO_MAXIMO_DE_PARCELAS] parcelasDoAluguel; 
    }

    ContratoLocacao private contratoLocacao;


    constructor(string memory _nomeDoLocador, string memory _nomeDoLocatario, uint256 valorInicialDasParcelas) {
        contratoLocacao.nomeDoLocador = _nomeDoLocador;
        contratoLocacao.nomeDoLocatario = _nomeDoLocatario;
        for (uint8 i=0; i<NUMERO_MAXIMO_DE_PARCELAS; i++){
            contratoLocacao.parcelasDoAluguel[i]=valorInicialDasParcelas;
        }
    }


    function retornarValorDoAluguel(uint256 posicaoDaParcela) external view returns(uint256 valorDaParcela) {
        
        return contratoLocacao.parcelasDoAluguel[posicaoDaParcela -1];
    }

    function retornarNomeDoLocadorELocatario() external view returns(string memory, string memory){
        return (contratoLocacao.nomeDoLocador, contratoLocacao.nomeDoLocatario);
    }

    function alterarNome(uint256 tipoPessoa, string memory nome) external{
        require(tipoPessoa > 0 && tipoPessoa < 3, "tipoPessoa deve ser 1 para Locador ou 2 para Locatario.");
        require(bytes(nome).length > 0, "Nome invalido");

        if(tipoPessoa == TIPO_PESSOA_LOCADOR){
            contratoLocacao.nomeDoLocador = nome;
        } else if (tipoPessoa == TIPO_PESSOA_LOCATARIO){
            contratoLocacao.nomeDoLocatario = nome;
        }
    }

    function reajustarParcelas(uint256 posicaoDaParcelaInicialParaReajuste, uint256 valorDoReajuste) external{
        require(verificarValidadeDoMes(posicaoDaParcelaInicialParaReajuste), "Mes escolhido para o reajuste e invalido.");
        for (uint256 i = posicaoDaParcelaInicialParaReajuste-1; i < NUMERO_MAXIMO_DE_PARCELAS; i++){
            contratoLocacao.parcelasDoAluguel[i] = contratoLocacao.parcelasDoAluguel[i] + valorDoReajuste;
        }
    }

    function verificarValidadeDoMes(uint256 posicaoDaParcelaInicialParaReajuste) internal pure returns(bool){
        return posicaoDaParcelaInicialParaReajuste >= 0 && posicaoDaParcelaInicialParaReajuste <=NUMERO_MAXIMO_DE_PARCELAS;
    } 

}

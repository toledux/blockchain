//SPDX-License-Identifier: CC-BY-4.0

pragma solidity 0.8.20;

//0xF48271227483f717F9fE08296360B45e0A70C5cC
contract Aula3 {
    uint8 constant NUMERO_MAXIMO_DE_PARCELAS = 36; 
    uint8 constant TAMANHO_MINIMO_DO_NOME = 3;

    enum TipoPessoa{ INVALIDO, LOCADOR, LOCATARIO }

    struct Pessoa{
        string nome;
        TipoPessoa tipo;
    }

    struct ContratoLocacao{
        Pessoa locador;
        Pessoa locatario;
        uint256[NUMERO_MAXIMO_DE_PARCELAS] boletos; 
    }

    modifier stringValido(string memory nome, string memory valor){
        bytes memory nomeBytes = bytes(nome);
        bytes memory campoBytes = bytes("Campo ");
        bytes memory naoValidoBytes = bytes(" nao e um valor valido");
        bytes memory concatenated = abi.encodePacked(campoBytes, nomeBytes, naoValidoBytes);
       
        require(bytes(valor).length >= TAMANHO_MINIMO_DO_NOME, string(concatenated));
        _;
    }

    modifier tipoPessoaValido(TipoPessoa tipoPessoa){
        require(
            tipoPessoa == TipoPessoa.LOCADOR || 
            tipoPessoa == TipoPessoa.LOCATARIO, "Tipo de pessoa informada e invalido." );
        _;
    }
    

    ContratoLocacao private contratoLocacao;

    constructor(string memory nomeDoLocador, string memory nomeDoLocatario, uint256 valorDasParcelas) {
        contratoLocacao.locador = Pessoa(nomeDoLocador,TipoPessoa.LOCADOR);
        contratoLocacao.locatario = Pessoa(nomeDoLocatario, TipoPessoa.LOCATARIO);
        for (uint8 i=0; i<NUMERO_MAXIMO_DE_PARCELAS; i++){
            contratoLocacao.boletos[i] = valorDasParcelas;
        }
    }

    function retornarValorDoAluguel(uint8 parcelaDoBoleto) external view returns(uint256 valorDaParcela) {
        require(verificarValidadeDaParcela(parcelaDoBoleto), "A parcela escolhida e invalida.");
        return contratoLocacao.boletos[parcelaDoBoleto -1];
    }

    function retornarNomeDoLocadorELocatario() external view returns(Pessoa memory, Pessoa memory){
        return (contratoLocacao.locador, contratoLocacao.locatario);
    }

    function alterarNome(TipoPessoa tipoPessoa, string memory nome) 
        external 
        stringValido("nome",nome) 
        tipoPessoaValido(tipoPessoa)
        {
            if(TipoPessoa.LOCADOR == tipoPessoa){
                contratoLocacao.locador.nome = nome;
            } else if(TipoPessoa.LOCATARIO == tipoPessoa){
                contratoLocacao.locatario.nome = nome;
            }
    }

    function reajustarParcelas(uint8 parcelaInicialParaReajuste, uint256 valorDoReajuste) external{
        require(verificarValidadeDaParcela(parcelaInicialParaReajuste), "A parcela escolhida para o reajuste e invalida.");
        for (uint256 i = parcelaInicialParaReajuste-1; i < NUMERO_MAXIMO_DE_PARCELAS; i++){
            contratoLocacao.boletos[i] = contratoLocacao.boletos[i] + valorDoReajuste;
        }
    }

    function verificarValidadeDaParcela(uint8 parcelaDoBoleto) internal pure returns(bool){
        return parcelaDoBoleto > 0 && parcelaDoBoleto <=NUMERO_MAXIMO_DE_PARCELAS;
    } 

}

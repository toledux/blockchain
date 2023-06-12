//SPDX-License-Identifier: CC-BY-4.0

pragma solidity 0.8.20;

//0xc957DaEba660CeB43BAe0B944C88F3b22137eF66
contract Aula3 {
    uint8 constant NUMERO_MAXIMO_DE_PARCELAS = 36; 
    uint8 constant TAMANHO_MINIMO_DO_NOME = 3;

    enum TipoPessoa{ INVALIDO, LOCADOR, LOCATARIO }

    struct Pessoa{
        string nome;
        TipoPessoa tipo;
    }

    struct Boleto{
        uint8 numeroDoBoleto;
        uint256 valor;
    }

    struct ContratoLocacao{
        mapping(TipoPessoa => Pessoa) partes;
        mapping(uint8 => Boleto) boletos;
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

    ContratoLocacao private contratoDeLocacao;

    constructor(string memory nomeDoLocador, string memory nomeDoLocatario, uint256 valorDasParcelas) {
        contratoDeLocacao.partes[TipoPessoa.LOCADOR] = Pessoa(nomeDoLocador,TipoPessoa.LOCADOR);
        contratoDeLocacao.partes[TipoPessoa.LOCATARIO] = Pessoa(nomeDoLocatario, TipoPessoa.LOCATARIO);
        for (uint8 i=1; i<=NUMERO_MAXIMO_DE_PARCELAS; i++){
            contratoDeLocacao.boletos[i] = Boleto(i,valorDasParcelas);
        }
    }

    function retornarValorDoAluguel(uint8 parcelaDoBoleto) external view returns(uint256 valorDaParcela) {
        require(verificarValidadeDaParcela(parcelaDoBoleto), "A parcela escolhida e invalida.");
        return contratoDeLocacao.boletos[parcelaDoBoleto].valor;
    }

    function retornarNomeDoLocadorELocatario() external view returns(Pessoa memory, Pessoa memory){
        return (contratoDeLocacao.partes[TipoPessoa.LOCADOR], contratoDeLocacao.partes[TipoPessoa.LOCATARIO]);
    }

    function alterarNome(TipoPessoa tipoPessoa, string memory nome) 
    external stringValido("nome",nome) tipoPessoaValido(tipoPessoa) {
        contratoDeLocacao.partes[tipoPessoa].nome = nome;
    }

    function reajustarParcelas(uint8 parcelaInicialParaReajuste, uint256 valorDoReajuste) external{
        require(verificarValidadeDaParcela(parcelaInicialParaReajuste), "A parcela escolhida para o reajuste e invalida.");
        for (uint8 i = parcelaInicialParaReajuste; i <= NUMERO_MAXIMO_DE_PARCELAS; i++){
            contratoDeLocacao.boletos[i].valor = contratoDeLocacao.boletos[i].valor + valorDoReajuste;
        }
    }

    function verificarValidadeDaParcela(uint8 parcelaDoBoleto) internal pure returns(bool){
        return parcelaDoBoleto > 0 && parcelaDoBoleto <=NUMERO_MAXIMO_DE_PARCELAS;
    } 

}

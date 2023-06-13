//SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

contract Ownable {
    address internal owner;
    
    modifier onlyOwner() {
        require(msg.sender == owner, unicode"Somente o proprietário pode executar esta ação");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

}

contract Imobiliaria is Ownable {
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

    struct ContratoDeLocacao {
        bytes32 identificadorDoContrato;
        mapping(TipoPessoa => Pessoa) partes;
        mapping(uint8 => Boleto) boletos;
        bool contratoCriado;
    }

    modifier stringValido(string memory nome, string memory valor){
        bytes memory nomeBytes = bytes(nome);
        bytes memory campoBytes = bytes("Campo ");
        bytes memory naoValidoBytes = bytes(unicode" não é um valor valido");
        bytes memory concatenated = abi.encodePacked(campoBytes, nomeBytes, naoValidoBytes);
       
        require(bytes(valor).length >= TAMANHO_MINIMO_DO_NOME, string(concatenated));
        _;
    }

    modifier tipoPessoaValido(TipoPessoa tipoPessoa){
        require(
            tipoPessoa == TipoPessoa.LOCADOR || 
            tipoPessoa == TipoPessoa.LOCATARIO, unicode"Tipo de pessoa informada é invalido." );
        _;
    }

    modifier contratoExiste(bytes32 identificadorDoContrato){
        require(contratosDeLocacao[identificadorDoContrato].contratoCriado, "Contrato inexistente!");
        _;
    }

    mapping(bytes32 => ContratoDeLocacao) internal contratosDeLocacao;
    uint256 public quantidadeDeContratos;

    constructor() {  }

    function criarNovoContratoDeLocacao(string memory nomeDoLocador, string memory nomeDoLocatario, uint256 valorDasParcelas) external onlyOwner returns(bytes32){
        bytes32 chave =  bytes32(block.timestamp);
        ContratoDeLocacao storage contrato = contratosDeLocacao[chave];

        contrato.identificadorDoContrato = chave;
        contrato.partes[TipoPessoa.LOCADOR] = Pessoa(nomeDoLocador,TipoPessoa.LOCADOR);
        contrato.partes[TipoPessoa.LOCATARIO] = Pessoa(nomeDoLocatario, TipoPessoa.LOCATARIO);

        for (uint8 i=1; i<=NUMERO_MAXIMO_DE_PARCELAS; i++){
            contrato.boletos[i] = Boleto(i,valorDasParcelas);
        }
        quantidadeDeContratos++;
        contrato.contratoCriado=true;
        return contrato.identificadorDoContrato;
    }

    function retornarValorDoAluguel(bytes32 identificadorDoContrato, uint8 parcelaDoBoleto) 
    external view contratoExiste(identificadorDoContrato) returns(uint256 valorDaParcela) {
        require(verificarValidadeDaParcela(parcelaDoBoleto), unicode"A parcela escolhida é inválida.");
        return contratosDeLocacao[identificadorDoContrato].boletos[parcelaDoBoleto].valor;
    }

    function retornarNomeDoLocadorELocatario(bytes32 identificadorDoContrato) 
    external view contratoExiste(identificadorDoContrato) returns(Pessoa memory, Pessoa memory){
        return (contratosDeLocacao[identificadorDoContrato].partes[TipoPessoa.LOCADOR], 
                contratosDeLocacao[identificadorDoContrato].partes[TipoPessoa.LOCATARIO]);
    }

    function alterarNome(bytes32 identificadorDoContrato, TipoPessoa tipoPessoa, string memory nome) 
    external contratoExiste(identificadorDoContrato) onlyOwner stringValido("nome",nome) tipoPessoaValido(tipoPessoa) {
        contratosDeLocacao[identificadorDoContrato].partes[tipoPessoa].nome = nome;
    }

    function reajustarParcelas(bytes32 identificadorDoContrato, uint8 parcelaInicialParaReajuste, uint256 valorDoReajuste) 
    external contratoExiste(identificadorDoContrato) onlyOwner{
        require(verificarValidadeDaParcela(parcelaInicialParaReajuste), unicode"A parcela escolhida para o reajuste é inválida.");
        for (uint8 i = parcelaInicialParaReajuste; i <= NUMERO_MAXIMO_DE_PARCELAS; i++){
            contratosDeLocacao[identificadorDoContrato].boletos[i].valor = 
                contratosDeLocacao[identificadorDoContrato].boletos[i].valor + valorDoReajuste;
        }
    }

    function verificarValidadeDaParcela(uint8 parcelaDoBoleto) internal pure returns(bool){
        return parcelaDoBoleto > 0 && parcelaDoBoleto <=NUMERO_MAXIMO_DE_PARCELAS;
    } 

}

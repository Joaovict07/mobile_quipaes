package modelo;

public class Produto {
    private String nomeProduto;
    private double precoProduto;
    private String descricaoProduto;
    private int flagPromocao;
    private String linkImagem;

    // Construtor vazio
    public Produto() {}

    // Getters e Setters
    public String getNomeProduto() { return nomeProduto; }
    public void setNomeProduto(String nomeProduto) { this.nomeProduto = nomeProduto; }

    public double getPrecoProduto() { return precoProduto; }
    public void setPrecoProduto(double precoProduto) { this.precoProduto = precoProduto; }

    public String getDescricaoProduto() { return descricaoProduto; }
    public void setDescricaoProduto(String descricaoProduto) { this.descricaoProduto = descricaoProduto; }

    public int getFlagPromocao() { return flagPromocao; }
    public void setFlagPromocao(int flagPromocao) { this.flagPromocao = flagPromocao; }

    public String getLinkImagem() { return linkImagem; }
    public void setLinkImagem(String linkImagem) { this.linkImagem = linkImagem; }
}
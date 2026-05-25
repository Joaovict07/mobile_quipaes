package dao;

import modelo.Produto;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ProdutoDAO {
    // Configurações do seu banco de dados
    private static final String URL = "jdbc:mysql://localhost:3306/quipaesDB";
    private static final String USER = "root";
    private static final String PASS = "12345";

    public List<Produto> listarTodos() {
        List<Produto> listaProdutos = new ArrayList<>();
        String sql = "SELECT nome_produto, preco_produto, descricao_produto, flag_promocao, link_imagem FROM produtos";

        try {
            // Carrega o driver do MySQL (Necessário adicionar o mysql-connector-java.jar ao projeto)
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS);
                 PreparedStatement stmt = conn.prepareStatement(sql);
                 ResultSet rs = stmt.executeQuery()) {

                while (rs.next()) {
                    Produto p = new Produto();
                    p.setNomeProduto(rs.getString("nome_produto"));
                    p.setPrecoProduto(rs.getDouble("preco_produto"));
                    p.setDescricaoProduto(rs.getString("descricao_produto"));
                    p.setFlagPromocao(rs.getInt("flag_promocao"));
                    p.setLinkImagem(rs.getString("link_imagem"));
                    
                    listaProdutos.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return listaProdutos;
    }
}
package controle;

import dao.ProdutoDAO;
import modelo.Produto;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/api/produtos")
public class ProdutoService extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Define que a resposta será em formato JSON e com suporte a acentuação
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        ProdutoDAO dao = new ProdutoDAO();
        List<Produto> produtos = dao.listarTodos();
        
        PrintWriter out = response.getWriter();
        
        // Montando o JSON manualmente para evitar dependências externas
        out.print("[");
        for (int i = 0; i < produtos.size(); i++) {
            Produto p = produtos.get(i);
            out.print("{");
            out.print("\"nome_produto\": \"" + p.getNomeProduto() + "\",");
            out.print("\"preco_produto\": " + p.getPrecoProduto() + ",");
            out.print("\"descricao_produto\": \"" + p.getDescricaoProduto() + "\",");
            out.print("\"flag_promocao\": " + p.getFlagPromocao() + ",");
            out.print("\"link_imagem\": \"" + p.getLinkImagem() + "\"");
            out.print("}");
            
            // Adiciona vírgula se não for o último item
            if (i < produtos.size() - 1) {
                out.print(",");
            }
        }
        out.print("]");
        out.flush();
    }
}
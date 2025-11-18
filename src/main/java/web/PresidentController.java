package web;

import metier.entities.RoleClub;
import metier.entities.Utilisateur;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/president")
public class PresidentController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Vérification de sécurité : Est-ce vraiment un président ?
        HttpSession session = req.getSession();
        RoleClub president = (RoleClub) session.getAttribute("president");

        if (president == null) {
            resp.sendRedirect("accueil");
            return;
        }

        // Affiche une page spécifique ou la page d'accueil avec des options en plus
        // Pour l'instant, renvoyons vers index.jsp mais le header affichera "Mon Bureau"
        req.getRequestDispatcher("index.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // À implémenter : Création d'événement, suppression de membre, etc.
        String action = req.getParameter("action");
        // ... logique métier
        resp.sendRedirect("president");
    }
}
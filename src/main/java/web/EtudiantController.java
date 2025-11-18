package web;

import metier.entities.MembreClub;
import metier.entities.Utilisateur;
import metier.service.IGestionClubService;
import metier.service.impl.GestionClubServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/etudiant")
public class EtudiantController extends HttpServlet {

    private IGestionClubService service = new GestionClubServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("home.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        Utilisateur user = (Utilisateur) session.getAttribute("user");

        // Sécurité : Si pas connecté, redirection login
        if (user == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String action = req.getParameter("action");
        if("monEspace".equals(action)) {
            // Afficher tous les clubs auxquels l'étudiant appartient
            List<MembreClub> mesClubs = service.consulterMesClubs(user.getUtilisateurID());
            req.setAttribute("mesClubs", mesClubs);
            req.getRequestDispatcher("student/espace.jsp").forward(req, resp);

        }
        else if("allClubs".equals(action)) {
            req.getRequestDispatcher("student/espace.jsp").forward(req, resp);


        }
        else if ("rejoindreClub".equals(action)) {
            int clubId = Integer.parseInt(req.getParameter("clubId"));
            service.adhererAuClub(user.getUtilisateurID(), clubId);

            // Mise à jour de l'utilisateur en session pour voir les changements
            // (Dans une vraie app, on rechargerait l'user depuis la DB)
            resp.sendRedirect("accueil?msg=adhesion_ok");
        }
        else if ("participerEvent".equals(action)) {
            int eventId = Integer.parseInt(req.getParameter("eventId"));
            service.sInscrireEvenement(user.getUtilisateurID(), eventId);
            resp.sendRedirect("accueil?msg=inscription_ok");
        }
    }
}
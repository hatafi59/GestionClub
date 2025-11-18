package web;

import metier.entities.Evenement;
import metier.entities.MembreClub;
import metier.entities.Utilisateur;
import metier.service.IGestionClubService;
import metier.service.impl.GestionClubServiceImpl;
import metier.entities.Club; // Import manquant

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
        HttpSession session = req.getSession();
        Utilisateur user = (Utilisateur) session.getAttribute("user");


        // 1. SÉCURITÉ
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String action = req.getParameter("action");

        // 2. Aiguillage
        if ("monEspace".equals(action)) {
            // --- PAGE MES CLUBS ---
            resp.sendRedirect("/student/espace.jsp");
        }
        else if("home".equals(action)) {
            resp.sendRedirect("/common/home.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        Utilisateur user = (Utilisateur) session.getAttribute("user");
        String ctx = req.getContextPath();

        if (user == null) {
            resp.sendRedirect(ctx + "/login.jsp");
            return;
        }
        String action = req.getParameter("action");

        try {
            if ("rejoindreClub".equals(action)) {
                int clubId = Integer.parseInt(req.getParameter("clubId"));
                service.adhererAuClub(user.getUtilisateurID(), clubId);

                // Mise à jour session
                updateSessionData(session, user.getUtilisateurID());

                // CORRECTION : On redirige vers /etudiant, pas /accueil
                resp.sendRedirect(ctx + "/etudiant?msg=adhesion_ok");
            }

            else if ("participerEvent".equals(action)) {
                int eventId = Integer.parseInt(req.getParameter("eventId"));
                service.sInscrireEvenement(user.getUtilisateurID(), eventId);

                // Mise à jour session
                updateSessionData(session, user.getUtilisateurID());

                // CORRECTION : On redirige vers /etudiant
                resp.sendRedirect(ctx + "/etudiant?msg=inscription_ok");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(ctx + "/etudiant?error=operation_failed");
        }
    }

    private void updateSessionData(HttpSession session, int userId) {
        // Cette méthode est très utile pour garder la barre de navigation à jour
        List<MembreClub> mesClubs = service.consulterMesClubs(userId);
        // List<Evenement> mesEvents = service.consulterMesEvenements(userId); // Si besoin
        session.setAttribute("mesClubs", mesClubs);
    }
}
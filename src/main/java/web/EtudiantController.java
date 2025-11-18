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
        String ctx = req.getContextPath();


        // 1. SÉCURITÉ
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String action = req.getParameter("action");

        // 2. Aiguillage
        if ("monEspace".equals(action)) {
            // A. On charge les données fraîches
            chargerDonneesEspace(req, session, user.getUtilisateurID());
            // B. IMPORTANT : On utilise forward (pas redirect) pour garder les données
            // Assurez-vous que le fichier est dans : src/main/webapp/etudiant/espace.jsp
            req.getRequestDispatcher("/studant/espace.jsp").forward(req, resp);
        }
        else if( action==null || "home".equals(action)) {
            resp.sendRedirect(ctx +"/common/home.jsp");
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

                updateSessionData(session, user.getUtilisateurID());
                // Redirection vers le contrôleur avec un message
                resp.sendRedirect(ctx + "/etudiant?action=monEspace&msg=adhesion_ok");
            }
            else if ("participerEvent".equals(action)) {
                int eventId = Integer.parseInt(req.getParameter("eventId"));
                service.sInscrireEvenement(user.getUtilisateurID(), eventId);

                // Pas besoin d'updateSessionData pour les events sauf si affichés en session
                resp.sendRedirect(ctx + "/etudiant?action=monEspace&msg=inscription_ok");
            }
            else if ("quitterClub".equals(action)) {
                int clubId = Integer.parseInt(req.getParameter("clubId"));
                service.quitterClub(user.getUtilisateurID(), clubId);

                updateSessionData(session, user.getUtilisateurID());
                resp.sendRedirect(ctx + "/etudiant?action=monEspace&msg=quitter_ok");
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(ctx + "/etudiant?action=monEspace&error=operation_failed");
        }
    }

    private void chargerDonneesEspace(HttpServletRequest req, HttpSession session, int userId) {
        List<MembreClub> mesClubs = service.consulterMesClubs(userId);
        List<Evenement> mesEvents = service.consulterMesEvenements(userId);

        // Mise à jour Session (pour le menu/header)
        session.setAttribute("mesClubs", mesClubs);
        session.setAttribute("mesEvents", mesEvents);

        // Mise à jour Requête (pour l'affichage immédiat dans la JSP)
        req.setAttribute("listMesClubs", mesClubs);
        req.setAttribute("listMesEvents", mesEvents);
    }

    private void updateSessionData(HttpSession session, int userId) {
        session.setAttribute("mesClubs", service.consulterMesClubs(userId));
        // Optionnel si vous stockez aussi les events en session
        session.setAttribute("mesEvents", service.consulterMesEvenements(userId));
    }
}
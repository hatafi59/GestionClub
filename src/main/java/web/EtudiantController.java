package web;

import metier.entities.Club;
import metier.entities.Evenement;
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
        HttpSession session = req.getSession();
        Utilisateur user = (Utilisateur) session.getAttribute("user");

        // 1. SÉCURITÉ
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/");
            return;
        }

        String action = req.getParameter("action");

        // 2. AIGUILLAGE
        if ("monEspace".equals(action)) {
            // A. On charge les données fraîches pour l'espace étudiant
            chargerDonneesEspace(req, session, user.getUtilisateurID());

            // B. CORRECTION : Ne pas inclure 'ctx' dans le dispatcher
            req.getRequestDispatcher("/studant/espace.jsp").forward(req, resp);
        }
        else if (action == null || "home".equals(action)) {
            // A. CHARGEMENT DES DONNÉES (Nécessaire car la session est vide au login avec JWT)
            List<Club> clubs = service.consulterTousLesClubs();
            List<Evenement> events = service.consulterTousLesEvenements();
            List<MembreClub> mesClubs = service.consulterMesClubs(user.getUtilisateurID());

            // B. On injecte les données dans la requête
            req.setAttribute("tousClubs", clubs);
            req.setAttribute("tousEvents", events);
            req.setAttribute("mesClubs", mesClubs); // Utile pour les boutons "Adhérer" (déjà membre ?)

            // C. CORRECTION : Utiliser forward() au lieu de redirect pour conserver les données
            req.getRequestDispatcher("/common/home.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        Utilisateur user = (Utilisateur) session.getAttribute("user");
        String ctx = req.getContextPath();

        if (user == null) {
            resp.sendRedirect(ctx + "/");
            return;
        }
        String action = req.getParameter("action");

        try {
            if ("rejoindreClub".equals(action)) {
                int clubId = Integer.parseInt(req.getParameter("clubId"));
                service.adhererAuClub(user.getUtilisateurID(), clubId);

                // Redirection vers monEspace (qui rechargera les données fraîches via doGet)
                resp.sendRedirect(ctx + "/etudiant?action=monEspace&msg=adhesion_ok");
            }
            else if ("participerEvent".equals(action)) {
                int eventId = Integer.parseInt(req.getParameter("eventId"));
                service.sInscrireEvenement(user.getUtilisateurID(), eventId);

                resp.sendRedirect(ctx + "/etudiant?action=monEspace&msg=inscription_ok");
            }
            else if ("quitterClub".equals(action)) {
                int clubId = Integer.parseInt(req.getParameter("clubId"));
                service.quitterClub(user.getUtilisateurID(), clubId);

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

        // Mise à jour Session (pour la persistance si navigation via header)
        session.setAttribute("mesClubs", mesClubs);
        session.setAttribute("mesEvents", mesEvents);

        // Mise à jour Requête (pour l'affichage immédiat)
        req.setAttribute("listMesClubs", mesClubs);
        req.setAttribute("listMesEvents", mesEvents);
    }

    // La méthode updateSessionData est devenue redondante car "monEspace" recharge tout,
    // mais on peut la laisser ou la supprimer. Je l'ai supprimée ci-dessus pour alléger le code.
}
package web;

import metier.entities.*;
import metier.service.IGestionClubService;
import metier.service.impl.GestionClubServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "HomeServlet", urlPatterns = {"/accueil", ""})
public class AccueilServlet extends HttpServlet {

    private IGestionClubService service = new GestionClubServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        HttpSession session = req.getSession();

        // 1. Vérification : Est-on connecté ?
        Utilisateur user = (Utilisateur) session.getAttribute("user");
        if (user == null) {
            // Ici on garde sendRedirect car on change complètement de contexte (vers le login)
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // 2. Chargement des données (Le travail lourd)
        // Ces listes sont mises dans la "valise" (req)
        List<Club> clubs = service.consulterTousLesClubs();
        List<Evenement> events = service.consulterTousLesEvenements();
        List<MembreClub> mesClubs = service.consulterMesClubs(user.getUtilisateurID());
        List<Evenement> mesEvents = service.consulterMesEvenements(user.getUtilisateurID());
        req.setAttribute("tousClubs", clubs);
        req.setAttribute("tousEvents", events);
        req.setAttribute("mesClubs", mesClubs);
        req.setAttribute("mesEvents", mesEvents);



        // 3. Aiguillage vers les autres SERVLETS

        // Récupération des rôles
        Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
        if (isAdmin == null) isAdmin = false;
        RoleClub rolePresident = (RoleClub) session.getAttribute("president");

        if (isAdmin) {

            req.getRequestDispatcher("/admin").forward(req, resp);
            return;
        }
        if (rolePresident != null) {
            // On passe le relais à la Servlet Président avec toutes les données
            req.getRequestDispatcher("/president").forward(req, resp);
            return;
        }
        // Si c'est un étudiant normal, on l'envoie vers la Servlet Etudiant
        req.getRequestDispatcher("/etudiant").forward(req, resp);
    }
}
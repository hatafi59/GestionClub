// src/main/java/web/AdminController.java
package web;

import metier.entities.Club;
import metier.entities.Utilisateur;
import metier.service.IGestionClubService;
import metier.service.impl.GestionClubServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/admin")
public class AdminController extends HttpServlet {

    private IGestionClubService service = new GestionClubServiceImpl();

    // Classe utilitaire pour transférer les stats à la JSP
    public static class ClubStat {
        public Club club;
        public int nombreMembresActifs; // Renommage pour clarté
        public int nombreEvenements;
        public int nombreAdhesionsEnAttente; // NOUVEAU
        public int nombreAdhesionsRefusees; // NOUVEAU

        public ClubStat(Club club, int membres, int events, int pending, int rejected) {
            this.club = club;
            this.nombreMembresActifs = membres;
            this.nombreEvenements = events;
            this.nombreAdhesionsEnAttente = pending;
            this.nombreAdhesionsRefusees = rejected;
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
        String ctx = req.getContextPath();

        // 1. SÉCURITÉ
        if (isAdmin == null || !isAdmin) {
            resp.sendRedirect(ctx + "/login.jsp");
            return;
        }
        String sortBy = req.getParameter("sortBy");
        if (sortBy == null) sortBy = "membres"; // Tri par défaut

        // --- 2. LOGIQUE DE CHARGEMENT DES DONNÉES ET STATISTIQUES ---
        // A. Chargement de tous les clubs pour les stats et la gestion
        List<Club> tousClubs = service.consulterTousLesClubs();
        req.setAttribute("tousClubs", tousClubs);
        // B. Calcul et tri des statistiques des clubs
        List<ClubStat> clubStats = tousClubs.stream().map(club -> {
            int membresActifs = service.compterMembresClub(club.getClubID()); // Compte ACCEPTE/ACTIF
            int events = service.compterEvenementsClub(club.getClubID());
            // Récupération des nouveaux compteurs
            int pending = service.compterAdhesionsParStatut(club.getClubID(), "EN_ATTENTE");
            int rejected = service.compterAdhesionsParStatut(club.getClubID(), "REFUSE");

            return new ClubStat(club, membresActifs, events, pending, rejected);
        }).collect(Collectors.toList());

        // C. Tri de la liste des clubs selon le paramètre
        switch (sortBy) {
            case "evenements":
                clubStats.sort((s1, s2) -> Integer.compare(s2.nombreEvenements, s1.nombreEvenements));
                break;
            case "en_attente":
                clubStats.sort((s1, s2) -> Integer.compare(s2.nombreAdhesionsEnAttente, s1.nombreAdhesionsEnAttente));
                break;
            case "refusees":
                clubStats.sort((s1, s2) -> Integer.compare(s2.nombreAdhesionsRefusees, s1.nombreAdhesionsRefusees));
                break;
            case "membres":
            default:
                // Tri par défaut : membres actifs (nombreMembresActifs)
                clubStats.sort((s1, s2) -> Integer.compare(s2.nombreMembresActifs, s1.nombreMembresActifs));
                break;
        }
        req.setAttribute("clubStats", clubStats);
        req.setAttribute("sortBy", sortBy); // Passer le critère de tri à la JSP


        // D. Chargement ou recherche d'utilisateurs
        String action = req.getParameter("action");
        String motCle = req.getParameter("motCle");
        String searchType = req.getParameter("searchType"); // NOUVEAU: Type de recherche
        List<Utilisateur> listeUtilisateurs = new ArrayList<>(); // Initialiser à vide

        if (motCle != null && !motCle.trim().isEmpty()) {
            req.setAttribute("motCleRecherche", motCle); // Pour afficher dans l'input

            if ("par_email".equals(searchType)) {
                // Recherche exacte par email
                Utilisateur u = service.trouverUtilisateurParEmail(motCle.trim());
                if (u != null) {
                    listeUtilisateurs.add(u);
                }
            } else {
                // Recherche par mot clé (Nom, Prénom, Email) - Comportement par défaut
                listeUtilisateurs = service.rechercherUtilisateurs(motCle.trim());
            }
        } else {
            // Charger tous les utilisateurs pour le dashboard si aucun terme de recherche
            if (!"recherche".equals(action)) { // Éviter de charger tout si l'utilisateur a juste cliqué sur rechercher sans mot clé
                listeUtilisateurs = service.consulterTousLesUtilisateurs();
            }
        }
        req.setAttribute("listeUtilisateurs", listeUtilisateurs);
        req.setAttribute("searchType", searchType); // Pour maintenir l'état du radio-bouton
        req.setAttribute("sizeTotalUtilisateurs", service.consulterTousLesUtilisateurs().size());


        // 3. Redirige vers le dashboard admin
        req.getRequestDispatcher("/admin/dashboard.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
        String ctx = req.getContextPath();

        if (isAdmin == null || !isAdmin) {
            resp.sendRedirect(ctx + "/login.jsp");
            return;
        }

        String action = req.getParameter("action");
        String redirectURL = ctx + "/admin?tab=management"; // Redirection par défaut vers la gestion

        try {
            // --- GESTION DES CLUBS ---
            if ("creerClub".equals(action)) {
                String nom = req.getParameter("nom");
                String description = req.getParameter("description");
                if (nom != null && !nom.trim().isEmpty()) {
                    Club newClub = new Club();
                    newClub.setNom(nom.trim());
                    newClub.setDescription(description != null ? description.trim() : "");
                    service.creerClub(newClub); // Crée le club et les rôles de base (PRESIDENT/MEMBRE)
                    redirectURL = ctx + "/admin?msg=club_cree&tab=management";
                }
            } else if ("supprimerClub".equals(action)) {
                int clubId = Integer.parseInt(req.getParameter("clubId"));
                service.supprimerClub(clubId);
                redirectURL = ctx + "/admin?msg=club_supprime&tab=management";
            }
            // --- GESTION DES UTILISATEURS ---
            else if ("assignerPresident".equals(action)) {
                int userId = Integer.parseInt(req.getParameter("userId"));
                int clubId = Integer.parseInt(req.getParameter("clubId"));

                // La méthode assignerPresident gère la création de l'adhésion si elle n'existe pas.
                service.assignerPresident(userId, clubId);
                redirectURL = ctx + "/admin?msg=president_assigne&tab=management";

            } else if ("supprimerUtilisateur".equals(action)) {
                int userId = Integer.parseInt(req.getParameter("userId"));
                service.supprimerUtilisateur(userId);
                redirectURL = ctx + "/admin?msg=utilisateur_supprime&tab=management";
            } else {
                redirectURL = ctx + "/admin?error=action_inconnue";
            }

        } catch (Exception e) {
            e.printStackTrace();
            redirectURL = ctx + "/admin?tab=management&error=operation_failed";
        }

        resp.sendRedirect(redirectURL);
    }
}
package web;

import metier.entities.*;
import metier.service.IGestionClubService;
import metier.service.impl.GestionClubServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/president")
public class PresidentController extends HttpServlet {

    private IGestionClubService service = new GestionClubServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        // --- GESTION DE L'ONGLET ACTIF ---
        String currentTab = req.getParameter("tab");
        if (currentTab == null) currentTab = "membres";
        req.setAttribute("currentTab", currentTab);

        // 1. SÉCURITÉ : Vérifier si c'est bien un président
        RoleClub rolePresident = (RoleClub) session.getAttribute("president");
        if (rolePresident == null) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }

        int clubId = rolePresident.getClub().getClubID();

        // --- RECUPERATION DES MEMBRES ---
        List<MembreClub> tousMembres = service.voirMembresDuClub(clubId);

        // --- GESTION DE LA RECHERCHE ET FILTRAGE ---
        String searchMember = req.getParameter("searchMember");
        if (searchMember != null && !searchMember.trim().isEmpty()) {
            String motCle = searchMember.toLowerCase().trim();

            // Correction : Ajout de vérifications null pour éviter le crash (NullPointerException)
            tousMembres = tousMembres.stream()
                    .filter(m -> {
                        Utilisateur u = m.getUtilisateur();
                        if (u == null) return false;
                        String nom = u.getNomUtilisateur();
                        String email = u.getEmail();
                        return (nom != null && nom.toLowerCase().contains(motCle)) ||
                                (email != null && email.toLowerCase().contains(motCle));
                    })
                    .collect(Collectors.toList());

        }

        // 2. RÉPARTITION DES DONNÉES (Basée sur la liste filtrée)
        // A. Les membres
        List<MembreClub> demandesEnAttente = tousMembres.stream()
                .filter(m -> "EN_ATTENTE".equals(m.getStatut()))
                .collect(Collectors.toList());

        List<MembreClub> membresActifs = tousMembres.stream()
                .filter(m -> "ACCEPTE".equals(m.getStatut()) || "ACTIF".equals(m.getStatut()))
                .collect(Collectors.toList());

        // B. Les événements du club
        List<Evenement> eventsClub = service.consulterEvenementsDuClub(clubId);

        // 3. TRANSFERT À LA VUE
        req.setAttribute("demandesEnAttente", demandesEnAttente);
        req.setAttribute("membresActifs", membresActifs);
        req.setAttribute("eventsClub", eventsClub);
        req.setAttribute("monClub", rolePresident.getClub());
        req.setAttribute("searchMember", searchMember); // Pour réafficher dans l'input
        req.getRequestDispatcher("/president/bureau.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Le code doPost reste identique, je le remets pour que le fichier soit complet
        HttpSession session = req.getSession();
        RoleClub rolePresident = (RoleClub) session.getAttribute("president");
        String ctx = req.getContextPath();

        if (rolePresident == null) {
            resp.sendRedirect(ctx + "/");
            return;
        }

        String action = req.getParameter("action");
        int clubId = rolePresident.getClub().getClubID();
        String currentTab = "membres";

        try {
            if ("accepterMembre".equals(action)) {
                int membreId = Integer.parseInt(req.getParameter("membreId"));
                service.accepterDemandeAdhesion(membreId);
            }
            else if ("refuserMembre".equals(action)) {
                int membreId = Integer.parseInt(req.getParameter("membreId"));
                service.refuserDemandeAdhesion(membreId);
            }
            else if ("bannirMembre".equals(action)) {
                int userId = Integer.parseInt(req.getParameter("userId"));
                service.supprimerMembreDuClub(userId, clubId);
            }
            else if ("changerRole".equals(action)) {
                int userId = Integer.parseInt(req.getParameter("userId"));
                String nouveauRole = req.getParameter("nouveauRole");
                Utilisateur userConnecte = (Utilisateur) session.getAttribute("user");
                if(userConnecte.getUtilisateurID() != userId) {
                    service.assignRoleToMember(userId, clubId, nouveauRole);
                }
            }
            else if ("creerEvent".equals(action)) {
                currentTab = "events";
                String titre = req.getParameter("titre");
                String description = req.getParameter("description");
                String dateStr = req.getParameter("date");
                Date dateEvent = (dateStr != null && !dateStr.isEmpty()) ?
                        java.sql.Timestamp.valueOf(dateStr.replace("T", " ") + ":00") : new Date();

                Evenement evt = new Evenement();
                evt.setTitre(titre);
                evt.setDescription(description);
                evt.setDateEvenement(dateEvent);
                evt.setClub(rolePresident.getClub());
                service.creerEvenement(evt);
            }
            else if ("supprimerEvent".equals(action)) {
                currentTab = "events";
                int eventId = Integer.parseInt(req.getParameter("eventId"));
                service.supprimerEvenement(eventId);
            }

            resp.sendRedirect(ctx + "/president?msg=action_ok&tab=" + currentTab);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(ctx + "/president?error=error_technique");
        }
    }
}
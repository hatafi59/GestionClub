package web;

import metier.entities.*;
import metier.service.IGestionClubService;
import metier.service.impl.GestionClubServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/president")
public class PresidentController extends HttpServlet {

    private IGestionClubService service = new GestionClubServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();

        // 1. SÉCURITÉ : Vérifier si c'est bien un président
        RoleClub rolePresident = (RoleClub) session.getAttribute("president");
        if (rolePresident == null) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp"); // ou page erreur
            return;
        }

        int clubId = rolePresident.getClub().getClubID();

        // 2. RÉCUPÉRATION DES DONNÉES
        // A. Les membres
        List<MembreClub> tousMembres = service.voirMembresDuClub(clubId);

        // On sépare les demandes en attente des membres actifs pour l'affichage
        List<MembreClub> demandesEnAttente = tousMembres.stream()
                .filter(m -> "EN_ATTENTE".equals(m.getStatut()))
                .collect(Collectors.toList());

        List<MembreClub> membresActifs = tousMembres.stream()
                .filter(m -> "ACCEPTE".equals(m.getStatut()) || "ACTIF".equals(m.getStatut())) // Gère les deux cas au cas où
                .collect(Collectors.toList());

        // B. Les événements du club
        // NOTE: Assurez-vous d'avoir ajouté la méthode dans le Service comme indiqué plus haut.
        // Sinon utilisez : service.consulterTousLesEvenements().stream().filter(e -> e.getClub().getClubID() == clubId).collect(Collectors.toList());
        List<Evenement> eventsClub = service.consulterEvenementsDuClub(clubId);

        // 3. TRANSFERT À LA VUE
        req.setAttribute("demandesEnAttente", demandesEnAttente);
        req.setAttribute("membresActifs", membresActifs);
        req.setAttribute("eventsClub", eventsClub);
        req.setAttribute("monClub", rolePresident.getClub());

        req.getRequestDispatcher("/president/dashboard.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        RoleClub rolePresident = (RoleClub) session.getAttribute("president");
        String ctx = req.getContextPath();

        if (rolePresident == null) {
            resp.sendRedirect(ctx + "/login.jsp");
            return;
        }

        String action = req.getParameter("action");
        int clubId = rolePresident.getClub().getClubID();

        try {
            // --- GESTION MEMBRES ---
            if ("accepterMembre".equals(action)) {
                int membreId = Integer.parseInt(req.getParameter("membreId"));
                service.accepterDemandeAdhesion(membreId);
                resp.sendRedirect(ctx + "/president?msg=membre_accepte");
            }
            else if ("refuserMembre".equals(action)) {
                int membreId = Integer.parseInt(req.getParameter("membreId"));
                service.refuserDemandeAdhesion(membreId);
                resp.sendRedirect(ctx + "/president?msg=membre_refuse");
            }
            else if ("bannirMembre".equals(action)) {
                int membreId = Integer.parseInt(req.getParameter("membreId"));
                // On utilise la méthode delete générique du DAO via le service
                // Attention: il faut une méthode deleteMembreById dans le service ou utiliser supprimerMembreDuClub avec UserID
                // Ici on suppose qu'on passe l'ID technique de MembreClub
                // Amélioration Service nécessaire ou usage astucieux :
                // service.supprimerMembreClub(membreId); -> Créons cette méthode ou adaptons.
                // Pour l'instant, utilisons la méthode existante qui prend userId et clubId.
                // Il faudrait récupérer le userId depuis le membreId, mais simplifions :
                // AJOUTEZ service.supprimerAdhesion(int id) dans votre service pour faire simple.
                // Sinon :
                int userId = Integer.parseInt(req.getParameter("userId"));
                service.supprimerMembreDuClub(userId, clubId);
                resp.sendRedirect(ctx + "/president?msg=membre_banni");
            }

            // --- GESTION ÉVÉNEMENTS ---
            else if ("creerEvent".equals(action)) {
                String titre = req.getParameter("titre");
                String description = req.getParameter("description");
                String dateStr = req.getParameter("date"); // Format HTML date-local : yyyy-MM-ddTHH:mm

                // Parsing simple de la date (ISO 8601)
                Date dateEvent = (dateStr != null && !dateStr.isEmpty()) ?
                        java.sql.Timestamp.valueOf(dateStr.replace("T", " ") + ":00") : new Date();

                Evenement evt = new Evenement();
                evt.setTitre(titre);
                evt.setDescription(description);
                evt.setDateEvenement(dateEvent);
                evt.setClub(rolePresident.getClub());

                service.creerEvenement(evt);
                resp.sendRedirect(ctx + "/president?msg=event_created");
            }
            else if ("supprimerEvent".equals(action)) {
                int eventId = Integer.parseInt(req.getParameter("eventId"));
                service.supprimerEvenement(eventId);
                resp.sendRedirect(ctx + "/president?msg=event_deleted");
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(ctx + "/president?error=error_technique");
        }
    }
}
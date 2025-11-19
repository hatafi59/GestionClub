package web;

import metier.entities.*;
import metier.service.IGestionClubService;
import metier.service.impl.GestionClubServiceImpl;
import org.mindrot.jbcrypt.BCrypt;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "AuthServlet", urlPatterns = {"/auth"})
public class AuthServlet extends HttpServlet {

    private static final String ACTION_LOGIN = "login";
    private static final String ACTION_REGISTER = "register";
    private static final String ACTION_LOGOUT = "logout";

    private IGestionClubService service = new GestionClubServiceImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");

        if (ACTION_LOGIN.equals(action)) {
            handleLogin(req, resp);
        } else if (ACTION_REGISTER.equals(action)) {
            handleRegister(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String ctx = req.getContextPath();

        if (ACTION_LOGOUT.equals(action)) {
            HttpSession session = req.getSession(false);
            if (session != null) {
                session.invalidate();
            }
        }
        // Redirection toujours vers l'accueil (index)
        resp.sendRedirect(ctx + "/");
    }

    // --- LOGIQUE MÉTIER ---

    private void handleLogin(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String pass = req.getParameter("password");
        String ctx = req.getContextPath();

        Utilisateur user = service.authentifier(email, pass);

        if (user != null) {
            HttpSession session = req.getSession();
            session.setAttribute("user", user);

            // Chargement des données pour la session
            List<Club> clubs = service.consulterTousLesClubs();
            List<Evenement> events = service.consulterTousLesEvenements();
            session.setAttribute("tousClubs", clubs);
            session.setAttribute("tousEvents", events);
            List<MembreClub> mesClubs = service.consulterMesClubs(user.getUtilisateurID());
            session.setAttribute("mesClubs", mesClubs);
            List<Evenement> mesEvents = service.consulterMesEvenements(user.getUtilisateurID());
            session.setAttribute("mesEvents", mesEvents);

            // Rôles
            RoleClub president = service.isPresident(user.getUtilisateurID());
            session.setAttribute("president", president);

            boolean isAdmin = user.getRoles().stream()
                    .anyMatch(r -> "ADMIN".equalsIgnoreCase(r.getNomRole()));
            session.setAttribute("isAdmin", isAdmin);

            // Redirection selon le rôle
            if (isAdmin) {
                resp.sendRedirect(ctx + "/admin");
            } else if (president != null) {
                resp.sendRedirect(ctx + "/president");
            } else {
                resp.sendRedirect(ctx + "/etudiant");
            }

        } else {
            // ERREUR LOGIN : On renvoie vers index.jsp avec un attribut spécifique "loginError"
            req.setAttribute("loginError", "Email ou mot de passe incorrect.");
            // IMPORTANT : Il faut recharger les données pour l'index car on fait un forward
            chargerDonneesIndex(req);
            req.getRequestDispatcher("/index.jsp").forward(req, resp);
        }
    }

    private void handleRegister(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            String nom = req.getParameter("username");
            String email = req.getParameter("email");
            String pass = req.getParameter("password");
            String niveau = req.getParameter("niveauEtude");

            // 1. Validation basique
            if (estVide(nom) || estVide(email) || estVide(pass)) {
                failRegister(req, resp, "Tous les champs sont obligatoires.");
                return;
            }

            // 2. Vérification existence email
            if (service.emailExiste(email)) {
                failRegister(req, resp, "Cet email est déjà utilisé.");
                return;
            }

            // 3. Hashage et Création
            String hash = BCrypt.hashpw(pass, BCrypt.gensalt());
            Utilisateur newUser = new Utilisateur();
            newUser.setNomUtilisateur(nom.trim());
            newUser.setEmail(email.trim());
            newUser.setMotDePasseHash(hash);
            newUser.setNiveauEtude(niveau != null ? niveau.trim() : "");

            Utilisateur createdUser = service.creerCompte(newUser);
            service.assignerRole(createdUser.getUtilisateurID(), "ETUDIANT");

            // SUCCÈS : On renvoie vers index avec un message de succès (qui ouvrira le Login)
            req.setAttribute("message", "Compte créé avec succès ! Veuillez vous connecter.");
            chargerDonneesIndex(req);
            req.getRequestDispatcher("/index.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            failRegister(req, resp, "Erreur technique lors de l'inscription.");
        }
    }

    private void failRegister(HttpServletRequest req, HttpServletResponse resp, String errorMsg) throws ServletException, IOException {
        req.setAttribute("registerError", errorMsg); // Attribut spécifique "registerError"
        chargerDonneesIndex(req);
        req.getRequestDispatcher("/index.jsp").forward(req, resp);
    }

    private boolean estVide(String str) {
        return str == null || str.trim().isEmpty();
    }

    // Méthode utilitaire pour éviter la page blanche (index vide) lors du forward
    private void chargerDonneesIndex(HttpServletRequest req) {
        List<Club> clubs = service.consulterTousLesClubs();
        List<Evenement> events = service.consulterTousLesEvenements();
        req.setAttribute("tousClubs", clubs);
        req.setAttribute("tousEvents", events);
    }
}
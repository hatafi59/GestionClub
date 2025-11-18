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
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String ctx = req.getContextPath();

        if (ACTION_LOGOUT.equals(action)) {
            HttpSession session = req.getSession(false); // Récupère la session s'il y en a une
            if (session != null) {
                session.invalidate(); // 1. On détruit la session côté serveur
            }
        }

        // 2. IMPORTANT : On redirige vers la SERVLET "/index"
        // Si on redirige vers "/index.jsp", la page sera vide (pas de données).
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

            // --- CORRECTION : Charger les données de l'utilisateur TOUT DE SUITE ---
            List<Club> clubs = service.consulterTousLesClubs();
            List<Evenement> events = service.consulterTousLesEvenements();
            session.setAttribute("tousClubs", clubs);
            session.setAttribute("tousEvents", events);
            List<MembreClub> mesClubs = service.consulterMesClubs(user.getUtilisateurID());
            session.setAttribute("mesClubs", mesClubs);
            List<Evenement> mesEvents = service.consulterMesEvenements(user.getUtilisateurID());
            session.setAttribute("mesEvents", mesEvents);
            // ----------------------------------------------------------------------

            // Rôles
            RoleClub president = service.isPresident(user.getUtilisateurID());
            session.setAttribute("president", president);

            boolean isAdmin = user.getRoles().stream()
                    .anyMatch(r -> "ADMIN".equalsIgnoreCase(r.getNomRole()));
            session.setAttribute("isAdmin", isAdmin);

            System.out.println("LOGIN SUCCESS : " + user.getEmail());
            System.out.println("isAdmin = " + isAdmin);
            System.out.println("isPresident = " + (president != null));

            if (isAdmin) {
                resp.sendRedirect(ctx + "/admin");
            } else if (president != null) {
                resp.sendRedirect(ctx + "/president");
            } else {
                // Vers la servlet Etudiant
                resp.sendRedirect(ctx + "/etudiant");
            }

        } else {
            req.setAttribute("error", "Email ou mot de passe incorrect.");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
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
                req.setAttribute("error", "Tous les champs sont obligatoires.");
                req.getRequestDispatcher("register.jsp").forward(req, resp);
                return;
            }

            // 2. Vérification existence email
            if (service.emailExiste(email)) {
                req.setAttribute("error", "Cet email est déjà utilisé.");
                req.getRequestDispatcher("register.jsp").forward(req, resp);
                return;
            }

            // 3. Hashage
            String hash = BCrypt.hashpw(pass, BCrypt.gensalt());

            // 4. Création
            Utilisateur newUser = new Utilisateur();
            newUser.setNomUtilisateur(nom.trim());
            newUser.setEmail(email.trim());
            newUser.setMotDePasseHash(hash);
            newUser.setNiveauEtude(niveau != null ? niveau.trim() : "");

            Utilisateur createdUser = service.creerCompte(newUser);

            // 5. Attribution rôle par défaut
            service.assignerRole(createdUser.getUtilisateurID(), "ETUDIANT");

            // 6. Succès -> Renvoi vers Login
            req.setAttribute("message", "Compte créé avec succès ! Veuillez vous connecter.");
            req.getRequestDispatcher("login.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Erreur technique lors de l'inscription.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
        }
    }

    private boolean estVide(String str) {
        return str == null || str.trim().isEmpty();
    }
}
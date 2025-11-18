package web;
import metier.entities.MembreClub;
import metier.entities.RoleClub;
import org.mindrot.jbcrypt.BCrypt;
import metier.entities.Utilisateur;
import metier.service.IGestionClubService;
import metier.service.impl.GestionClubServiceImpl;
// import org.mindrot.jbcrypt.BCrypt; // Idéalement, utilisez cette librairie

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.regex.Pattern;

@WebServlet("/auth")
public class AuthServlet extends HttpServlet {

    // Bonne pratique : Définir les actions en constantes pour éviter les fautes de frappe
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
            resp.sendRedirect("login.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if (ACTION_LOGOUT.equals(action)) {
            HttpSession session = req.getSession(false); // false = ne pas créer si elle n'existe pas
            if (session != null) {
                session.invalidate();
            }
            resp.sendRedirect("accueil");
        } else {
            resp.sendRedirect("accueil"); // Redirection par défaut
        }
    }

    // --- Méthodes privées pour séparer la logique (Clean Code) ---

    private void handleLogin(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String pass = req.getParameter("password");

        // Appel au service qui doit maintenant vérifier le hash (et non le texte clair)

        Utilisateur user = service.authentifier(email, pass);

        if (user != null) {
            HttpSession session = req.getSession();
            session.setAttribute("user", user);

            //verifier si il est president d'un club

            // Vérification sécurisée du rôle avec Stream
            boolean isAdmin = user.getRoles().stream()
                    .anyMatch(r -> "ADMIN".equalsIgnoreCase(r.getNomRole()));

            RoleClub president=service.isPresident(user.getUtilisateurID());
            if(president != null){
                session.setAttribute("president", president);
            }
            session.setAttribute("isAdmin", isAdmin);
            resp.sendRedirect("accueil");
        } else {
            req.setAttribute("error", "Email ou mot de passe incorrect.");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
        }
    }

    private void handleRegister(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            // 1. Récupération et nettoyage des entrées (.trim() enlève les espaces accidentels)
            String nom = req.getParameter("username"); // Attention: nom du champ dans register.jsp
            String email = req.getParameter("email");
            String pass = req.getParameter("password");
            String niveau = req.getParameter("niveauEtude");

            if (service.emailExiste(email)) { // Vous devez ajouter cette méthode dans votre Service
                req.setAttribute("error", "Cet email est déjà utilisé.");
                req.getRequestDispatcher("register.jsp").forward(req, resp);
                return;
            }

            // 4. Hachage du mot de passe (Sécurité)
            String hash = BCrypt.hashpw(pass, BCrypt.gensalt());

            // 5. Création de l'objet
            Utilisateur newUser = new Utilisateur();
            newUser.setNomUtilisateur(nom.trim());
            newUser.setEmail(email.trim());
            newUser.setMotDePasseHash(hash);
            newUser.setNiveauEtude(niveau.trim());
            // 6. Sauvegarde via le service
            Utilisateur  createdUser =service.creerCompte(newUser);

            service.assignerRole(createdUser.getUtilisateurID(), "ETUDIANT"); // Rôle par défaut
            // 7. Succès
            req.setAttribute("message", "Compte créé ! Connectez-vous.");
            req.getRequestDispatcher("login.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace(); // Log serveur (ne pas afficher au client)
            req.setAttribute("error", "Une erreur technique est survenue. Réessayez.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
        }
    }

    // Utilitaire pour vérifier les chaines vides
    private boolean estVide(String str) {
        return str == null || str.trim().isEmpty();
    }
}
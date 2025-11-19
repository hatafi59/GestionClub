package web.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import metier.entities.Utilisateur;
import metier.service.IGestionClubService;
import metier.service.impl.GestionClubServiceImpl;
import utils.JwtUtil;

import java.io.IOException;

// Appliquer sur toutes les URL privées
@WebFilter(urlPatterns = {"/admin/*", "/president/*", "/etudiant/*"})
public class JwtFilter implements Filter {

    private IGestionClubService service = new GestionClubServiceImpl();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String token = null;

        // 1. Récupérer le Token depuis les Cookies
        if (req.getCookies() != null) {
            for (Cookie c : req.getCookies()) {
                if ("auth_token".equals(c.getName())) {
                    token = c.getValue();
                    break;
                }
            }
        }

        // 2. Valider le Token
        String userEmail = (token != null) ? JwtUtil.validateTokenAndGetEmail(token) : null;

        if (userEmail != null) {
            // 3. Token valide : On charge l'utilisateur
            // Note : Pour optimiser, on pourrait stocker tout l'user dans le JWT,
            // mais charger depuis la DB est plus sûr pour avoir les données à jour.
            Utilisateur user = service.trouverUtilisateurParEmail(userEmail);

            // 4. On le met dans la REQUEST (et non la session) pour que les JSP/Contrôleurs le voient
            req.setAttribute("user", user);

            // IMPORTANT : Pour compatibilité avec votre code existant qui utilise session.getAttribute("user")
            // on peut le remettre temporairement en session, ou idéalement modifier vos contrôleurs.
            // Pour faciliter la transition, je mets à jour la session ici :
            req.getSession().setAttribute("user", user);
            // On remet aussi isAdmin, etc. si nécessaire
            boolean isAdmin = user.getRoles().stream().anyMatch(r -> "ADMIN".equalsIgnoreCase(r.getNomRole()));
            req.getSession().setAttribute("isAdmin", isAdmin);
            req.getSession().setAttribute("president", service.isPresident(user.getUtilisateurID()));

            chain.doFilter(request, response); // On laisse passer
        } else {
            // 4. Token invalide ou absent -> Redirection Login
            resp.sendRedirect(req.getContextPath() + "/index.jsp?loginError=Session expiree");
        }
    }
}
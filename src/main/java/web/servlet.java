package web;

import metier.entities.*;
import metier.service.IGestionClubService;
import metier.service.impl.GestionClubServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
@WebServlet(name = "Servlet", urlPatterns = {""})
public class servlet  extends HttpServlet{
    private IGestionClubService service = new GestionClubServiceImpl();
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Club> clubs = service.consulterTousLesClubs();
        List<Evenement> events = service.consulterTousLesEvenements();
        req.setAttribute("tousClubs", clubs);
        req.setAttribute("tousEvents", events);
        req.getRequestDispatcher("/index.jsp").forward(req, resp);
    }
}

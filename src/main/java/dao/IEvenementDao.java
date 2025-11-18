package dao;
import metier.entities.Evenement;
import java.util.List;

public interface IEvenementDao extends IGenericDao<Evenement> {
    List<Evenement> findByClub(int clubId);
    List<Evenement> findUpcomingEvents(); // Pour la page d'accueil
    List<Evenement> findByUser(int userId);
}
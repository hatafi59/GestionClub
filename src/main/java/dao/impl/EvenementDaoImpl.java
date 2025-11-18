package dao.impl;
import dao.IEvenementDao;
import dao.HibernateUtil;
import metier.entities.Evenement;
import org.hibernate.Session;
import java.util.Date;
import java.util.List;

public class EvenementDaoImpl extends GenericDaoImpl<Evenement> implements IEvenementDao {
    @Override
    public List<Evenement> findByClub(int clubId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery("FROM Evenement e WHERE e.club.clubID = :cid", Evenement.class)
                    .setParameter("cid", clubId)
                    .list();
        }
    }

    @Override
    public List<Evenement> findUpcomingEvents() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            // Événements dont la date est >= aujourd'hui
            return session.createQuery("FROM Evenement e WHERE e.dateEvenement >= :now ORDER BY e.dateEvenement ASC", Evenement.class)
                    .setParameter("now", new Date())
                    .list();
        }
    }

    @Override
    public List<Evenement> findByUser(int userId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery(
                    "SELECT pe.evenement FROM ParticipantEvenement pe WHERE pe.participant.utilisateurID = :uid", Evenement.class)
                    .setParameter("uid", userId)
                    .list();
        }
    }
}
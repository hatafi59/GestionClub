package dao.impl;
import dao.IParticipantEvenementDao;
import dao.HibernateUtil;
import metier.entities.ParticipantEvenement;
import org.hibernate.Session;
import java.util.List;

public class ParticipantEvenementDaoImpl extends GenericDaoImpl<ParticipantEvenement> implements IParticipantEvenementDao {

    @Override
    public List<ParticipantEvenement> findByEvenement(int eventId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery("FROM ParticipantEvenement pe WHERE pe.evenement.evenementID = :eid", ParticipantEvenement.class)
                    .setParameter("eid", eventId)
                    .list();
        }
    }

    @Override
    public boolean isParticipant(int userId, int eventId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            // CORRECTION ICI : 'pe.participant' au lieu de 'pe.utilisateur'
            Long count = session.createQuery(
                            "SELECT count(pe) FROM ParticipantEvenement pe WHERE pe.participant.utilisateurID = :uid AND pe.evenement.evenementID = :eid", Long.class)
                    .setParameter("uid", userId)
                    .setParameter("eid", eventId)
                    .uniqueResult();
            return count > 0;
        }
    }
}
package dao;
import metier.entities.ParticipantEvenement;
import java.util.List;

public interface IParticipantEvenementDao extends IGenericDao<ParticipantEvenement> {
    List<ParticipantEvenement> findByEvenement(int eventId);
    boolean isParticipant(int userId, int eventId);
}
package dao;
import metier.entities.MembreClub;
import java.util.List;

public interface IMembreClubDao extends IGenericDao<MembreClub> {
    // Récupérer tous les clubs auxquels un utilisateur spécifique appartient
    // Ex: Si utilisateurId = 1 (Utilisateur Alice), renvoie [MembreClub1, MembreClub2, ...]
    List<MembreClub> findByUtilisateur(int utilisateurId);
    // Récupérer tous les membres d'un club spécifique
    // Ex: Si clubId = 1 (Club AppsClub), renvoie [MembreClub1, MembreClub2, ...]
    List<MembreClub> findByClub(int clubId);
    MembreClub findByUserAndClub(int userId, int clubId);
    // verifier le statut d'un membre dans un club


}
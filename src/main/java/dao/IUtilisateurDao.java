package dao;
import metier.entities.Utilisateur;

public interface IUtilisateurDao extends IGenericDao<Utilisateur> {
    Utilisateur findByEmail(String email);
}
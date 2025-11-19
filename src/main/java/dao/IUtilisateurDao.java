package dao;
import metier.entities.Utilisateur;

import java.util.List;

public interface IUtilisateurDao extends IGenericDao<Utilisateur> {
    Utilisateur findByEmail(String email);
    List<Utilisateur> findAll();
    List<Utilisateur> findByMotCle(String motCle);
}
package dao;

import metier.entities.RoleClub;
import java.util.List;

public interface IRoleClubDao extends IGenericDao<RoleClub> {

    // Récupérer tous les rôles définis par un club spécifique
    // renvoie tous les rôles associés au club dont l'ID est clubId
    List<RoleClub> findAllRolesInClubId(int clubId);

    // Optionnel : Trouver un rôle précis dans un club par son nom
    RoleClub findByNomAndClub(String nomRole, int clubId);
    // Ex: Si nomRole = "Président" et clubId = 1, renvoie le rôle "Président" du club AppsClub

}
package dao;
import metier.entities.Role;

public interface IRoleDao extends IGenericDao<Role> {
    Role findByNom(String nomRole);
}
package dao.impl;
import dao.IRoleDao;
import dao.HibernateUtil;
import metier.entities.Role;
import org.hibernate.Session;

public class RoleDaoImpl extends GenericDaoImpl<Role> implements IRoleDao {
    @Override
    public Role findByNom(String nomRole) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery("FROM Role r WHERE r.nomRole = :nom", Role.class)
                    .setParameter("nom", nomRole)
                    .uniqueResult();
        }
    }
}
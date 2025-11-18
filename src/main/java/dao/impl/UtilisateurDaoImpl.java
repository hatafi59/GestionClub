package dao.impl;

import dao.IUtilisateurDao;
import dao.HibernateUtil;
import metier.entities.Utilisateur;
import org.hibernate.Session;
import org.hibernate.Transaction;
import metier.entities.Role;

public class UtilisateurDaoImpl extends GenericDaoImpl<Utilisateur> implements IUtilisateurDao {
    @Override
    public Utilisateur findByEmail(String email) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery("FROM Utilisateur u WHERE u.email = :email", Utilisateur.class)
                    .setParameter("email", email)
                    .uniqueResult();
        }
    }

}
package dao.impl;

import dao.IUtilisateurDao;
import dao.HibernateUtil;
import metier.entities.Utilisateur;
import org.hibernate.Session;
import org.hibernate.Transaction;
import metier.entities.Role;

import java.util.List;

public class UtilisateurDaoImpl extends GenericDaoImpl<Utilisateur> implements IUtilisateurDao {
    @Override
    public Utilisateur findByEmail(String email) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery("FROM Utilisateur u WHERE u.email = :email", Utilisateur.class)
                    .setParameter("email", email)
                    .uniqueResult();
        }
    }
    @Override
    public List<Utilisateur> findByMotCle(String motCle) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery("FROM Utilisateur u WHERE u.nomUtilisateur LIKE :mc OR u.email LIKE :mc", Utilisateur.class)
                    .setParameter("mc", "%" + motCle + "%")
                    .list();
        }
    }

}
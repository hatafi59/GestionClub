package dao.impl;
import dao.IMembreClubDao;
import dao.HibernateUtil;
import metier.entities.MembreClub;
import org.hibernate.Session;
import java.util.List;

public class MembreClubDaoImpl extends GenericDaoImpl<MembreClub> implements IMembreClubDao {

    @Override
    public List<MembreClub> findByUtilisateur(int utilisateurId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            // On récupère toutes les adhésions d'un étudiant
            return session.createQuery("FROM MembreClub mc WHERE mc.utilisateur.utilisateurID = :uid", MembreClub.class)
                    .setParameter("uid", utilisateurId)
                    .list();
        }
    }

    @Override
    public List<MembreClub> findByClub(int clubId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            // ATTENTION : Selon ton diagramme, MembreClub est lié à RoleClub, qui est lié à Club.
            // On doit faire une jointure implicite via le chemin : mc -> roleClub -> club
            return session.createQuery("FROM MembreClub mc WHERE mc.roleClub.club.clubID = :cid", MembreClub.class)
                    .setParameter("cid", clubId)
                    .list();
        }
    }
    @Override
    public MembreClub findByUserAndClub(int userId, int clubId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery("FROM MembreClub mc WHERE mc.utilisateur.utilisateurID = :uid AND mc.roleClub.club.clubID = :cid", MembreClub.class)
                    .setParameter("uid", userId)
                    .setParameter("cid", clubId)
                    .uniqueResult();
            }
        }

}
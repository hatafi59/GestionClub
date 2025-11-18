package dao.impl;

import dao.IRoleClubDao;
import dao.HibernateUtil;
import metier.entities.RoleClub;
import org.hibernate.Session;
import java.util.List;

public class RoleClubDaoImpl extends GenericDaoImpl<RoleClub> implements IRoleClubDao {

    @Override
    public List<RoleClub> findAllRolesInClubId(int clubId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            // La requête HQL sélectionne les RoleClub dont le 'club' a l'ID donné
            // Assurez-vous que dans l'entité RoleClub, vous avez bien un attribut :
            // @ManyToOne @JoinColumn(name="club_id") private Club club;
            return session.createQuery("FROM RoleClub rc WHERE rc.club.clubID = :cid", RoleClub.class)
                    .setParameter("cid", clubId)
                    .list();
        }
    }

    @Override
    public RoleClub findByNomAndClub(String nomRole, int clubId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM RoleClub rc WHERE rc.nomRole = :nom AND rc.club.clubID = :cid";
            return session.createQuery(hql, RoleClub.class)
                    .setParameter("nom", nomRole)
                    .setParameter("cid", clubId)
                    .uniqueResult();
        }
    }
}
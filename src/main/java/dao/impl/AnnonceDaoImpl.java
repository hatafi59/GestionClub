package dao.impl;
import dao.IAnnonceDao;
import dao.HibernateUtil;
import metier.entities.Annonce;
import org.hibernate.Session;
import java.util.List;

public class AnnonceDaoImpl extends GenericDaoImpl<Annonce> implements IAnnonceDao {
    @Override
    public List<Annonce> findByClub(int clubId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery("FROM Annonce a WHERE a.clubCible.clubID = :cid", Annonce.class)
                    .setParameter("cid", clubId)
                    .list();
        }
    }
}
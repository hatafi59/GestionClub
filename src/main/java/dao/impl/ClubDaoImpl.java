package dao.impl;
import dao.IClubDao;
import dao.HibernateUtil;
import metier.entities.Club;
import org.hibernate.Session;
import java.util.List;

public class ClubDaoImpl extends GenericDaoImpl<Club> implements IClubDao {
    @Override
    public List<Club> findByMotCle(String mc) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery("FROM Club c WHERE c.nom LIKE :mc OR c.description LIKE :mc", Club.class)
                    .setParameter("mc", "%" + mc + "%")
                    .list();
        }
    }
    @Override
    public Club findById(int id) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.get(Club.class, id);
        }
        catch(Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
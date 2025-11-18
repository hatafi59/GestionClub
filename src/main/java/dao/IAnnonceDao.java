package dao;
import metier.entities.Annonce;
import java.util.List;

public interface IAnnonceDao extends IGenericDao<Annonce> {
    List<Annonce> findByClub(int clubId);
}
package utils;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import metier.entities.Utilisateur;

import java.security.Key;
import java.util.Date;

public class JwtUtil {
    // Utilisez une clé secrète très forte en production (stockée en variable d'env)
    private static final String SECRET_KEY = "HakimiIsTheBestPlayerInMoroccanHistory2025"; // Minimum 32 caractères pour HS256
    private static final long EXPIRATION_TIME = 86400000; // 1 jour en millisecondes

    private static final Key key = Keys.hmacShaKeyFor(SECRET_KEY.getBytes());

    // Générer un Token
    public static String generateToken(Utilisateur utilisateur) {
        return Jwts.builder()
                .setSubject(utilisateur.getEmail()) // On utilise l'email comme identifiant
                .claim("id", utilisateur.getUtilisateurID())
                .claim("nom", utilisateur.getNomUtilisateur())
                // On peut ajouter les rôles ici pour éviter d'appeler la DB à chaque requête
                // .claim("roles", utilisateur.getRoles()....)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME))
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();
    }

    // Valider et extraire l'email (Subject)
    public static String validateTokenAndGetEmail(String token) {
        try {
            return Jwts.parserBuilder()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token)
                    .getBody()
                    .getSubject();
        } catch (JwtException | IllegalArgumentException e) {
            return null; // Token invalide ou expiré
        }
    }
}
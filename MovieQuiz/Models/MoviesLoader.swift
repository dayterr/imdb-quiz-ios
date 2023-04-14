//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Ruth Dayter on 10.04.2023.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    private let networkClient = NetworkClient()
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_8s2rzbkw") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {networkClient.fetch(url: mostPopularMoviesUrl) { response in
        switch response {
        case .success(let movies):
            do {
                let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: movies)
                handler(.success(mostPopularMovies))
            } catch {
                handler(.failure(error))
            }
        case .failure(let error):
            handler(.failure(error))
            
        }
        
    }
    }
}

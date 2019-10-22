#ifndef SSSS_COLLECT_CUH
#define SSSS_COLLECT_CUH

#include "ssss_reduce.cuh"
#include "utils_bytestorage.cuh"
#include "utils_warpaggr.cuh"
#include "utils_work.cuh"

namespace gpu {
namespace kernels {

template <typename T, typename Config>
__device__ void
collect_bucket_impl(const T* data, const poracle* oracles_packed,
                    const index* prefix_sum, T* out, index size,
                    oracle bucket, index* atomic, index workcount) {
    __shared__ index count;
    // initialize block-local count from prefix sum
    if (Config::algorithm::shared_memory && threadIdx.x == 0) {
        auto idx = partial_sum_idx(blockIdx.x, bucket, gridDim.x, Config::searchtree::width);
        count = prefix_sum[idx];
    }
    __syncthreads();
    // extract elements from the specified bucket
    blockwise_work<Config>(workcount, size, [&](index idx, mask amask) {
        // load bucket index
        auto packed = load_packed_bytes(oracles_packed, amask, idx);
        // determine target location
        index ofs{};
        if (Config::algorithm::shared_memory) {
            ofs = warp_aggr_atomic_count_predicate(&count, amask, packed == bucket);
        } else {
            ofs = warp_aggr_atomic_count_predicate(atomic, amask, packed == bucket);
        }
        // store element
        if (packed == bucket) {
            out[ofs] = data[idx];
        }
    });
}

template <typename T, typename Config>
__global__ void
collect_bucket(const T* data, const poracle* oracles_packed,
               const index* prefix_sum, T* out, index size, oracle bucket,
               index* atomic, index workcount) {
    collect_bucket_impl<T, Config>(data, oracles_packed, prefix_sum, out, size, bucket, atomic,
                                   workcount);
}

template <typename T, typename Config>
__global__ void
collect_bucket_indirect(const T* data, const poracle* oracles_packed,
                        const index* prefix_sum, T* out, index size,
                        const oracle* bucket_ptr, index* atomic, index workcount) {
    collect_bucket_impl<T, Config>(data, oracles_packed, prefix_sum, out, size, *bucket_ptr, atomic,
                                   workcount);
}

} // namespace kernels
} // namespace gpu

#endif // SSSS_COLLECT_CUH